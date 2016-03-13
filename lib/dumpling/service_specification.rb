module Dumpling
  class ServiceSpecification < BasicObject
    attr_reader :dependencies, :abstract_services

    def initialize
      @dependencies = {}
      @abstract_services = []
    end

    def class(klass = nil)
      klass.nil? ? @class : (@class = klass)
    end

    def instance(instance = nil)
      instance.nil? ? @instance : (@instance = instance)
    end

    def dependency(id, attribute: nil)
      dependencies[id] = { attribute: (attribute || guess_attribute(id)).to_sym }
    end

    def include(*ids)
      abstract_services.concat ids

      nil
    end

    private

    def guess_attribute(id)
      /(?<attribute>\w+)\z/i =~ id
      attribute || id
    end
  end
end
