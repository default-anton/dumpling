module Dumpling
  class DependenciesValidator
    def initialize(service_ids, abstract_service_ids)
      @service_ids = service_ids
      @abstract_service_ids = abstract_service_ids
    end

    def validate(specification)
      missing_services = missing_dependencies(specification).map(&:inspect)
      missing_abstract_services = missing_abstract_dependencies(specification).map do |id|
        "#{id.inspect}(abstract)"
      end
      missing_services.concat(missing_abstract_services)

      unless missing_services.empty?
        raise Errors::Service::MissingDependencies, missing_services.join(', ')
      end
    end

    private

    def missing_dependencies(specification)
      dependency_ids = specification.dependencies.keys
      dependency_ids.reject { |id| @service_ids.include?(id) }
    end

    def missing_abstract_dependencies(specification)
      specification.abstract_services.reject { |id| @abstract_service_ids.include?(id) }
    end
  end
end
