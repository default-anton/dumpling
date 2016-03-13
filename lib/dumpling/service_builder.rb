module Dumpling
  class ServiceBuilder
    def initialize(services, abstract_services)
      @services = services
      @abstract_services = abstract_services
    end
    
    def build(specification)
      instance = service_instance(specification)
      dependencies = service_dependencies(specification)
      dependencies.each do |service_id, options|
        service_specification = @services.get(service_id)
        instance.send("#{options[:attribute]}=", build(service_specification))
      end
      instance
    end
    
    private

    def service_instance(specification)
      specification.class.nil? ? specification.instance : specification.class.new
    end

    def service_dependencies(specification)
      dependencies = {}

      specification.abstract_services.each do |abstract_service_id|
        abstract_service_specification = @abstract_services.get(abstract_service_id)
        abstract_service_dependencies = service_dependencies(abstract_service_specification)
        dependencies.merge!(abstract_service_dependencies)
      end

      dependencies.merge!(specification.dependencies)
      dependencies
    end
  end
end
