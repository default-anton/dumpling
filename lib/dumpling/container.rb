module Dumpling
  class Container
    def initialize
      @id_list = Set.new
      @registry = {}
    end

    def get(id)
      id = id.to_sym
      fail(Errors::Container::Missing, id) unless @id_list.include?(id)
      specification = @registry[id]
      instance = build_instance(specification)
      inject_dependencies(instance, specification)
      instance
    end

    alias :[] get

    def set(id)
      id = id.to_sym
      fail(Errors::Container::Duplicate, id) if @id_list.include?(id)

      specification = Specification.new
      yield specification
      SpecificationValidator.new(@id_list, specification).validate!
      @registry[id] = specification
      @id_list << id

      nil
    end

    alias :[]= set

    def configure(&block)
      instance_eval(&block)
      self
    end

    private

    def build_instance(specification)
      specification.class.nil? ? specification.instance : specification.class.new
    end

    def inject_dependencies(instance, specification)
      specification.dependencies.each do |dependency|
        instance.send("#{dependency[:attr]}=", get(dependency[:id]))
      end
    end
  end
end
