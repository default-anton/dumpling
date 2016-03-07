module Dumpling
  class Container
    def initialize
      @services = Registry.new
      @abstract_services = Registry.new
    end

    def configure(&block)
      instance_eval(&block)
      self
    end

    def set(id, &block)
      fail(Errors::Container::Duplicate, id) if @services.has?(id)

      specification = create_specification(&block)
      @services.set(id, specification)

      id
    end

    def abstract(id, &block)
      fail(Errors::Container::Duplicate, id) if @abstract_services.has?(id)

      specification = create_abstract_specification(&block)
      @abstract_services.set(id, specification)

      id
    end

    def get(id)
      fail(Errors::Container::Missing, id) unless @services.has?(id)
      specification = @services.get(id)
      instance = build_instance(specification)
      inject_dependencies(instance, specification)
      instance
    end

    alias :[] get

    private

    def create_specification
      spec = ServiceSpecification.new
      yield spec
      class_validator.validate(spec)
      dependencies_validator.validate(spec)
      spec
    end

    def create_abstract_specification
      spec = ServiceSpecification.new
      yield spec
      dependencies_validator.validate(spec)
      spec
    end

    def class_validator
      @class_validator ||= ClassValidator.new
    end

    def dependencies_validator
      @dependencies_validator ||= DependenciesValidator.new(@services.keys, @abstract_services.keys)
    end

    def build_instance(specification)
      specification.class.nil? ? specification.instance : specification.class.new
    end

    def inject_dependencies(instance, specification)
      dependencies = find_dependencies(specification)
      dependencies.each do |id, dependency|
        instance.send("#{dependency[:attribute]}=", get(id))
      end
    end

    def find_dependencies(specification)
      dependencies = {}

      specification.abstract_services.each do |abstract_service_id|
        abstract_service = @abstract_services.get(abstract_service_id)
        dependencies.merge!(find_dependencies(abstract_service))
      end

      dependencies.merge!(specification.dependencies)
      dependencies
    end
  end
end
