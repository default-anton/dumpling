require 'set'

module Dumpling
  require 'dumpling/version'
  require 'dumpling/errors/base_error'
  require 'dumpling/errors/container'
  require 'dumpling/errors/specification'
  require 'dumpling/specification'
  require 'dumpling/specification_validator'
  require 'dumpling/registry'
  require 'dumpling/container'

  @container = Container.new

  class << self
    extend Forwardable

    def_delegators :@container, :set, :get, :[], :configure
  end
end
