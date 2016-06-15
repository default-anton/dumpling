[gem]: https://rubygems.org/gems/dumpling
[travis]: https://travis-ci.org/antonkuzmenko/dumpling
[codeclimate]: https://codeclimate.com/github/antonkuzmenko/dumpling
[coverage]: https://codeclimate.com/github/antonkuzmenko/dumpling/coverage
[gemnasium]: https://gemnasium.com/antonkuzmenko/dumpling

# Dumpling

[![Gem Version](https://badge.fury.io/rb/dumpling.svg)][gem]
[![Build Status](https://travis-ci.org/antonkuzmenko/dumpling.svg?branch=master)][travis]
[![Code Climate](https://codeclimate.com/github/antonkuzmenko/dumpling/badges/gpa.svg)][codeclimate]
[![Test Coverage](https://codeclimate.com/github/antonkuzmenko/dumpling/badges/coverage.svg)][coverage]
[![Dependency Status](https://gemnasium.com/antonkuzmenko/dumpling.svg)][gemnasium]

Dumpling provides you an unobtrusive way to manage dependencies.
What is unobtrusive? Unobtrusive means that you don't need to include a module or inherit a class anywhere in your project.
Dumpling does not tie your hands. All you have to do is just wire up dependencies.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dumpling'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dumpling

## Getting started

### Basics

Use ```instance``` for long-lived objects. ```#get``` returns the same instance at each call

Use ```class``` for short-lived objects. ```#get``` returns a new instance on every call

```ruby
class UsersRepository
  attr_writer :logger
end

Dumpling.configure do
  set :logger do |s|
    s.instance Logger.new(STDOUT) # => #<Logger:0x00000000e281a0>
  end

  set :users_repository do |s|
    s.class UsersRepository
    s.dependency :logger
  end
end

# Every time you invoke the #get method you get a new instance of the #class
Dumpling.get(:users_repository) # => #<UsersRepository:0x00000000ebee20>
Dumpling.get(:users_repository) # => #<UsersRepository:0x00000000e8a8f0>

# Every time you invoke the #get method you get the same predefined #instance
Dumpling.get(:logger) # => #<Logger:0x00000000e281a0>
Dumpling.get(:logger) # => #<Logger:0x00000000e281a0>
```

### Defining multiple dependencies

```ruby
container = Dumpling::Container.new
container.configure do
  set :logger do |s|
    s.instance Logger.new(STDOUT) # => #<Logger:0x00000000e281a0>
  end
  
  set :adapter do |s|
    s.instance PostgreSQLAdapter.new
    s.dependency :logger
  end

  set :users_repository do |s|
    s.class UsersRepository
    s.dependency :logger
    s.dependency :adapter
  end
end

class UsersRepository
  attr_accessor :logger, :adapter

  # You can mark a setter method as a private if you need
  private :adapter=, :logger=
end

container.get(:users_repository).logger # => #<Logger:0x00000000e281a0>
container[:users_repository].adapter.logger # => #<Logger:0x00000000e281a0>
# Logger will be injected every time an adapter is accessed
container[:adapter].logger # => #<Logger:0x00000000e281a0>
```

### Using namespaces

```ruby
container = Dumpling::Container.new
container.configure do
  # All that does not match [a-zA-Z0-9_] is a delimiter
  set :'billing:repositories:users' do |s|
    ...
  end
  
  set :'billing repositories users' do |s|
    ...
  end
  
  set :'billing.repositories.users' do |s|
    ...
  end
  
  # Delimiters can be mixed up
  set :'billing repositories-users' do |s|
    ...
  end
  
  set :'billing.commands.create' do |s|
    s.class Billing::Commands::Create
    # Will automatically guess the name of the attr_writer by the last word (attr_writer :users)
    s.dependency :'billing.repositories.users'
  end
  
  set :'billing.commands.open_dispute' do |s|
    s.class Billing::Commands::OpenDispute
    # Define the attr_writer explicitly (attr_writer :customers)
    s.dependency :'billing.repositories.users', attribute: :customers
  end
end
```

### Defining abstract services
Abstract service cannot be instantiated (accessed outside of the container). Whenever you include an abstract service into a regular service, you inherit its dependencies.

```ruby
container = Dumpling::Container.new
container.configure do
  abstract :repository do |s|
    s.dependency :logger # => #<Logger:0x00000000e281a0>
    s.dependency :persistence_adapter # => #<Sequel:0x00000000e281a0>
  end

  set :users_repository do |s|
    s.class UsersRepository
    s.include :repository
  end
end

container[:users_repository].logger # => #<Logger:0x00000000e281a0>
container[:users_repository].persistence_adapter # => #<Sequel:0x00000000e281a0>

container.configure do
  set :posts_repository do |s|
    s.class PostsRepository
    s.include :repository
    # overriding dependencies
    s.dependency :postgres_adapter, attribute: :persistence_adapter # => #<PG:0x00000000e281a0>
  end
end

container[:users_repository].persistence_adapter # => #<PG:0x00000000e281a0>
```

### Duplicating a container

```ruby
original = Dumpling::Container.new
original.configure do
  set :logger do |s|
    s.instance Logger.new(STDOUT)
  end
end

duplicate = original.dup
duplicate.get(:logger).equal?(original.get(:logger)) # => true

# Changes in the original container do not affect the duplicate and vise versa
original.set :game do |s|
  s.instance 'Tetris'
end

duplicate.get(:game) # => BOOM! raise Dumpling::Errors::Container::Missing
```

### Using Dumpling in tests

In order to mock services you can incorporate `Dumpling::TestContainer` in your test environment.
It has two additional methods, namely `#mock` and `#clear_mocks`

For instance, you have configured the following services:

```ruby
container = app_env == :test ? Dumpling::TestContainer.new : Dumpling::Container.new
container.configure do
  set :logger do |s|
    s.instance Logger.new(STDOUT)
  end

  set :worker do |s|
    s.instance Worker.new
    s.dependency :logger
  end
end
```

Add the following snippet into `spec_helper.rb`

```ruby
config.before :example do
  container.clear_mocks
end
```

An example of how to use `#mock`

```ruby
describe Worker do
  let(:test_logger) { double(:test_logger) }

  subject { container[:worker].logger }
  
  before do
    container.mock(:logger, test_logger)
  end

  it { is_expected.to eq test_logger }
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/antonkuzmenko/dumpling. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

