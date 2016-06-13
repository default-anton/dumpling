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

    def initialize_dup(original)
      @services = original.services.dup
      @abstract_services = original.abstract_services.dup
      super
    end

    def inspect
      services = @services.keys.sort.map do |id|
        service = @services.get(id)
        string = id.to_s
        string << service_object_str(service.instance, service.class).to_s
        string << dependencies_str(service.dependencies).to_s
        string
      end
      services.empty? ? to_s : "#{self}\n#{services.join("\n").strip}"
    end

    protected

    attr_reader :services, :abstract_services

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

    def service_object_str(service_instance, service_class)
      service_object = (service_instance.nil? ? service_class.inspect : service_instance.inspect)
      "\n --> #{service_instance.nil? ? 'class' : 'instance'}: #{service_object}"
    end

    def dependencies_str(dependencies)
      dependencies = dependencies.keys.join(',')
      "\n --> dependencies: #{dependencies}" unless dependencies.empty?
    end
  end
end
