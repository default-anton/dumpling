module Dumpling
  class Container
    attr_writer :validator_class

    def initialize
      @registry = Registry.new
      @validator_class = SpecificationValidator
    end

    def set(id, &block)
      fail(Errors::Container::Duplicate, id) if @registry.has?(id)

      specification = create_specification(&block)
      @registry.set(id, specification)

      id
    end

    def get(id)
      fail(Errors::Container::Missing, id) unless @registry.has?(id)
      specification = @registry.get(id)
      instance = build_instance(specification)
      inject_dependencies(instance, specification)
      instance
    end

    alias :[] get

    def configure(&block)
      instance_eval(&block)
      self
    end

    private

    def create_specification
      specification = Specification.new
      yield specification
      @validator_class.new(@registry.keys, specification).validate!
      specification
    end

    def build_instance(specification)
      specification.class.nil? ? specification.instance : specification.class.new
    end

    def inject_dependencies(instance, specification)
      specification.dependencies.each do |dependency|
        instance.send("#{dependency[:attribute]}=", get(dependency[:id]))
      end
    end
  end
end
