require 'set'

module Dumpling
  require 'dumpling/version'
  require 'dumpling/errors/base_error'
  require 'dumpling/errors/container'
  require 'dumpling/errors/service'
  require 'dumpling/service_specification'
  require 'dumpling/service_builder'
  require 'dumpling/class_validator'
  require 'dumpling/dependencies_validator'
  require 'dumpling/registry'
  require 'dumpling/container'

  @container = Container.new

  class << self
    extend Forwardable

    def_delegators :@container, :set, :get, :[], :configure
  end
end
