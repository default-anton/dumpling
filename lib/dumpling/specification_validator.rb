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
      unless @specification.class.nil? || @specification.instance.nil?
        fail Errors::Specification::Invalid,
             'Do not define both #class and #instance at the same time'
      end

      if @specification.class.nil? && @specification.instance.nil?
        fail Errors::Specification::Invalid, 'Define #class or #instance'
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
        .map { |e| e[:id] }
        .reject { |e| @id_list.include?(e) }
    end
  end
end
