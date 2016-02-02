# Dumpling

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

### Simple case

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

# Every time you invoke the #get method you will get a new instance of the #class
Dumpling.get(:users_repository) # => #<UsersRepository:0x00000000ebee20>
Dumpling.get(:users_repository) # => #<UsersRepository:0x00000000e8a8f0>

# Every time you invoke the #get method you will get the same predefined #instance
Dumpling.get(:logger) # => #<Logger:0x00000000e281a0>
Dumpling.get(:logger) # => #<Logger:0x00000000e281a0>
```

### Defining multiple dependencies

```ruby
container = Dumpling::Container.new
container.configure do
  set :adapter do |s|
    s.class PostgreSQLAdapter
  end

  set :logger do |s|
    s.instance Logger.new(STDOUT)
  end

  set :users_repository do |s|
    s.class UsersRepository
    s.dependency :logger
    s.dependency :adapter
  end
end

class UsersRepository
  attr_writer :logger, :adapter

  # You can mark a setter method as a private if you need
  private :adapter=
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/antonkuzmenko/dumpling. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

