# -*- coding: utf-8 -*-

module Termtter
  class JSONError < StandardError; end
  class RubytterProxy
    class FrequentAccessError < StandardError; end

    include Hookable

    attr_reader :rubytter

    def initialize(*args)
      @rubytter = Rubytter.new(*args)
    end

    def method_missing(method, *args, &block)
      if @rubytter.respond_to?(method)
        result = nil
        begin
          modified_args = args
          hooks = self.class.get_hooks("pre_#{method}")
          hooks.each do |hook|
            modified_args = hook.call(*modified_args)
          end

          from = Time.now
          Termtter::Client.logger.debug(
            "rubytter_proxy: #{method}(#{modified_args.inspect[1...-1]})")
          result = call_rubytter_or_use_cache(method, *modified_args, &block)
          Termtter::Client.logger.debug(
            "rubytter_proxy: #{method}(#{modified_args.inspect[1...-1]}), " +
            "%.2fsec" % (Time.now - from))

          self.class.call_hooks("post_#{method}", *args)
        rescue HookCanceled
        rescue TimeoutError => e
          Termtter::Client.logger.debug(
            "rubytter_proxy: #{method}(#{modified_args.inspect[1...-1]}) " +
            "#{e.message} #{'%.2fsec' % (Time.now - from)}")
          raise e
        rescue => e
          Termtter::Client.logger.debug(
            "rubytter_proxy: #{method}(#{modified_args.inspect[1...-1]}) #{e.message}")
          raise e
        end
        result
      else
        super
      end
    end

    def call_rubytter_or_use_cache(method, *args, &block)
      case method
      when :show
        unless status = cached_status(args[0])
          status = call_rubytter(method, *args, &block)
          store_status_cache(status)
        end
        status
      when :user
        unless user = cached_user(args[0])
          user = call_rubytter(method, *args, &block)
          store_user_cache(user)
        end
        user
      when :home_timeline, :user_timeline, :friends_timeline, :search
        statuses = call_rubytter(method, *args, &block)
        statuses.each do |status|
          store_status_cache(status)
        end
        statuses
      else
        call_rubytter(method, *args, &block)
      end
    end

    def cached_user(screen_name_or_id)
      user = Termtter::Client.memory_cache.get(['user', screen_name_or_id].join('-'))
      ActiveRubytter.new(user) if user
    end

    def cached_status(id)
      status = Termtter::Client.memory_cache.get(['status', id.to_i].join('-'))
      ActiveRubytter.new(status) if status
    end

    def store_status_cache(status)
      Termtter::Client.memory_cache.set(['status', status.id.to_i].join('-'), status.destructize, config.cache.expire)
      store_user_cache(status.user)
    end

    def store_user_cache(user)
      Termtter::Client.memory_cache.set(['user', user.id.to_i].join('-'), user.destructize, config.cache.expire)
      Termtter::Client.memory_cache.set(['user', user.screen_name].join('-'), user.destructize, config.cache.expire)
    end

    attr_accessor :safe_mode
    def safe
      new_instance = self.class.new(@rubytter)
      new_instance.safe_mode = true
      self.instance_variables.each{ |v|
        new_instance.instance_variable_set(v, self.instance_variable_get(v))
      }
      new_instance
    end

    def current_limit
      @limit_manager ||= LimitManager.new(@rubytter)
    end

    def call_rubytter(method, *args, &block)
      raise FrequentAccessError, 'avoided depletion of API resources' if @safe_mode && !self.current_limit.safe?
      config.retry.times do
        begin
          timeout(config.timeout) do
            begin
              return @rubytter.__send__(method, *args, &block)
            rescue JSON::ParserError => e
              tt = e.message.match(/<title>(.+)<\/title>/)
              t = 0 < tt.size ? " #{tt[0][0]}" : ""
              raise Termtter::JSONError, "JSON::ParserError#{t}"
            rescue SocketError => e
              if /nodename nor servname provided, or not known/ =~ e.message
                Termtter::Client.logger.error("Cannot connect to twitter...")
              else
                raise
              end
            end
          end
        rescue TimeoutError
        end
      end
      raise TimeoutError, 'execution expired'
    end

    class LimitManager
      def initialize(rubytter)
        @rubytter = rubytter
        @limit = nil
        @count = 0
      end

      def get
        @count += 1
        if @count > 5 || !@limit
          @count = 0
          @limit = @rubytter.limit_status
        end
        @limit
      end

      def safe?
        limit = self.get
        threshold = [(Time.parse(limit.reset_time) - Time.now) / 3600 - 0.1, 0.1].max * limit.hourly_limit
        threshold < limit.remaining_hits
      end
    end

  end
end
