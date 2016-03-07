module Dumpling
  class DependenciesValidator
    def initialize(services, abstract_services)
      @services = services
      @abstract_services = abstract_services
    end

    def validate(specification)
      missing_services = missing_dependencies(specification).map(&:inspect)
      missing_abstract_services = missing_abstract_dependencies(specification).map do |e|
        "#{e.inspect}(abstract)"
      end
      missing_services.concat(missing_abstract_services)

      unless missing_services.empty?
        fail Errors::Service::MissingDependencies, missing_services.join(', ')
      end
    end

    private

    def missing_dependencies(specification)
      dependency_ids = specification.dependencies.keys
      dependency_ids.reject { |e| @services.include?(e) }
    end

    def missing_abstract_dependencies(specification)
      specification.abstract_services.reject { |e| @abstract_services.include?(e) }
    end
  end
end
