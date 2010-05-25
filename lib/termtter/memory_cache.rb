module Termtter

  class MemoryCache
    # delegate to storage class

    def storage
      @storage ||= storage_class.new(config.cache.memcached_server)
    end

    def method_missing(method, *args, &block)
      storage.__send__(method, *args, &block)
    end

    protected
    def storage_class
      can_use_memcache? ? MemCache : MemCacheMock
    end

    def can_use_memcache?
      return unless config.cache.memcached_server
      begin
        require 'memcache'
        MemCache.new(config.cache.memcached_server).stats # when server is wrong, die here.
      rescue StandardError, LoadError
        false
      else
        true
      end
    end

    class MemCacheMock < SimpleDelegator
      def initialize(dummy_server)
        super(Hash.new)
        @keys = []
        @limit = 10000
      end

      def set(key, value, expiry = 0, raw = false)
        self[key] = try_clone value
        adjust(key)
        self
      end

      def get(key, raw = false)
        try_clone self[key]
      end

      def get_multi(*keys)
        results = {}
        keys.each{ |key|
          results[key] = try_clone self[key]
        }
        results
      end

      def stats
        { "total_items"=> length }
      end

      def flush_all(delay = 0)
        clear
      end

      protected

      def try_clone(a)
        a.clone rescue a
      end

      def adjust(key)
        return if @keys.include?(key)
        @keys << key
        delete(@keys.shift) while @keys.size > @limit
      end

    end
  end
end
