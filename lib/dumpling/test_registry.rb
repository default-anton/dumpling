module Dumpling
  class TestRegistry < Registry
    def initialize(child_registry = Registry.new)
      @child_registry = child_registry
      @all_keys = child_registry.keys.dup
      super()
    end

    def mock(id, value)
      @keys << id
      @all_keys << id
      @data[id] = value
    end

    def set(id, value)
      @all_keys << id
      @child_registry.set(id, value)
    end

    def get(id)
      has?(id, include_child: false) ? super : @child_registry.get(id)
    end

    def has?(id, include_child: true)
      keys(include_child: include_child).include?(id)
    end

    def keys(include_child: true)
      include_child ? @all_keys : @keys
    end

    def initialize_dup(original)
      super.tap do
        @child_registry = original.child_registry.dup
        @all_keys = original.all_keys.dup
        @keys = original.keys(include_child: false).dup
      end
    end

    protected

    attr_reader :child_registry, :all_keys
  end
end
