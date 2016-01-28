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

    def inject(id, attr: nil)
      dependencies << { id: id.to_sym, attr: (attr || guess_attribute(id)).to_sym }
    end

    private

    def guess_attribute(id)
      /(?<attr>\w+)\z/i =~ id
      attr || id
    end
  end
end
