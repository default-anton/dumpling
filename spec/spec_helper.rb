$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

if ENV['COVERAGE'] == 'true'
  require 'simplecov'

  SimpleCov.start do
    add_filter '/spec/'
  end
end

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'dumpling'
Dir['./spec/support/**/*.rb'].sort.each { |f| require f }
