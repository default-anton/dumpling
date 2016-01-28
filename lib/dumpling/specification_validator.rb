module Dumpling
  class SpecificationValidator
    def initialize(id_list, specification)
      @id_list = id_list
      @specification = specification
    end

    def validate!
      validate_value
      validate_dependencies
    end

    private

    def validate_value
      if @specification.class.nil? && @specification.instance.nil?
        fail Errors::Specification::Invalid, 'You must define #class or #instance'
      end
    end

    def validate_dependencies
      missing_deps = missing_dependencies

      unless missing_deps.empty?
        fail Errors::Specification::MissingDependencies, missing_deps.join(', ')
      end
    end

    def missing_dependencies
      @specification
        .dependencies
        .reject { |e| @id_list.include?(e[:id]) }
        .map { |e| e[:id] }
    end
  end
end
