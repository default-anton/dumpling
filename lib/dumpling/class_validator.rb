module Dumpling
  class ClassValidator
    def validate(specification)
      unless specification.class.nil? || specification.instance.nil?
        raise Errors::Service::Invalid,
              'Do not define both #class and #instance at the same time'
      end

      if specification.class.nil? && specification.instance.nil?
        raise Errors::Service::Invalid, 'Define #class or #instance'
      end
    end
  end
end
