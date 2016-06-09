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
      raise(Errors::Container::Duplicate, id) if @services.has?(id)

      specification = create_specification(&block)
      @services.set(id, specification)
      id
    end

    def abstract(id, &block)
      raise(Errors::Container::Duplicate, id) if @abstract_services.has?(id)

      specification = create_abstract_specification(&block)
      @abstract_services.set(id, specification)
      id
    end

    def get(id)
      raise(Errors::Container::Missing, id) unless @services.has?(id)

      specification = @services.get(id)
      build_service(specification)
    end

    alias :[] get

    def inspect
      services = @services.keys.sort.map do |id|
        service = @services.get(id)
        string = id.to_s
        service_object = (service.instance.nil? ? service.class.inspect : service.instance.inspect)
        string << "\n --> #{service.instance.nil? ? 'class' : 'instance'}: #{service_object}"
        dependencies = service.dependencies.keys.join(',')
        string << "\n --> dependencies: #{dependencies}" unless dependencies.empty?
        string
      end
      services.empty? ? to_s : "#{self}\n#{services.join("\n").strip}"
    end

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

    def build_service(specification)
      ServiceBuilder.new(@services, @abstract_services).build(specification)
    end
  end
end
