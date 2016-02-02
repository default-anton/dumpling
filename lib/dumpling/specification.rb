module Dumpling
  class Specification < BasicObject
    attr_accessor :dependencies

    def initialize
      self.dependencies = []
    end

    def class(klass = nil)
      klass.nil? ? @class : (@class = klass)
    end

    def instance(instance = nil)
      instance.nil? ? @instance : (@instance = instance)
    end

    def dependency(id, attribute: nil)
      dependencies << { id: id, attribute: (attribute || guess_attribute(id)).to_sym }
    end

    private

    def guess_attribute(id)
      /(?<attribute>\w+)\z/i =~ id
      attribute || id
    end
  end
end
