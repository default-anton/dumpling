module Dumpling
  class Registry
    attr_reader :keys

    def initialize
      @data = {}
      @keys = Set.new
    end

    def set(id, value)
      @data[id] = value
      @keys << id

      value
    end

    def get(id)
      @data[id]
    end

    def has?(id)
      @keys.include?(id)
    end
  end
end
