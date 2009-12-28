require 'delegate'

module Termtter
  class MemoryCache < SimpleDelegator
    attr_reader :limit

    def initialize(limit = 10000)
      super(Hash.new)
      @keys = []
      @limit = limit
    end

    def adjust(key)
      unless @keys.include?(key)
        @keys << key
        while @keys.size > limit
          delete(@keys.shift)
        end
      end
    end

    def []=(key, value)
      super
      adjust(key)
    end

    def store(key, value)
      super
      adjust(key)
    end
  end
end
