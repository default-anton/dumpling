module Dumpling
  class Registry
    attr_reader :keys

    def initialize
      @data = {}
      @keys = Set.new
    end

    def set(id, value)
      @keys << id
      @data[id] = value
    end

    def get(id)
      @data[id]
    end

    def has?(id)
      @keys.include?(id)
    end

    def initialize_dup(original)
      @data = original.data.dup
      @keys = original.keys.dup
      super
    end

    protected

    attr_reader :data
  end
end
