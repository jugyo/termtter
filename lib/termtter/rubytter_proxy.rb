begin
  require 'nokogiri'
rescue LoadError
end

module Termtter
  class JSONError < StandardError; end
  class RubytterProxy
    class FrequentAccessError < StandardError; end

    include Hookable

    attr_reader :rubytter

    def initialize(*args)
      @rubytter = OAuthRubytter.new(*args)
      @initial_args = args
    end

    def method_missing(method, *args, &block)
      return super if !@rubytter.respond_to?(method)
      result = nil
      begin
        modified_args = args
        hooks = self.class.get_hooks("pre_#{method}")
        hooks.each do |hook|
          modified_args = hook.call(*modified_args)
        end

        from = Time.now if Termtter::Client.logger.debug?
        Termtter::Client.logger.debug {
          "rubytter_proxy: #{method}(#{modified_args.inspect[1...-1]})"
        }
        result = call_rubytter_or_use_cache(method, *modified_args, &block)
        Termtter::Client.logger.debug {
          "rubytter_proxy: #{method}(#{modified_args.inspect[1...-1]}), " +
            "%.2fsec" % (Time.now - from)
        }

        self.class.call_hooks("post_#{method}", *args)
      rescue HookCanceled
      rescue TimeoutError => e
        Termtter::Client.logger.debug {
          "rubytter_proxy: #{method}(#{modified_args.inspect[1...-1]}) " +
            "#{e.message} #{'%.2fsec' % (Time.now - from)}"
        }
        raise e
      rescue => e
        Termtter::Client.logger.debug {
          "rubytter_proxy: #{method}(#{modified_args.inspect[1...-1]}) #{e.message}"
        }
        raise e
      end
      result
    end

    def call_rubytter_or_use_cache(method, *args, &block)
      case method
      when :show
        status = cached_status(args[0])
        unless status
          status = call_rubytter(method, *args, &block)
          store_status_cache(status)
        end
        status
      when :user
        user = cached_user(args[0])
        unless user
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
      user =
        Termtter::Client.memory_cache.get(
          ['user', Termtter::Client.normalize_as_user_name(screen_name_or_id.to_s)].join('-'))
      ActiveRubytter.new(user) if user
    end

    def cached_status(status_id)
      status =
        Termtter::Client.memory_cache.get(['status', status_id].join('-'))
      ActiveRubytter.new(status) if status
    end

    def store_status_cache(status)
      Termtter::Client.memory_cache.set(
        ['status', status.id].join('-'), status.to_hash, 3600 * 24 * 14)
      store_user_cache(status.user)
    end

    def store_user_cache(user)
      Termtter::Client.memory_cache.set(
        ['user', user.id.to_i].join('-'),
        user.to_hash, 3600 * 24)
      Termtter::Client.memory_cache.set(
        ['user', Termtter::Client.normalize_as_user_name(user.screen_name)].join('-'),
        user.to_hash, 3600 * 24)
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
      raise FrequentAccessError if @safe_mode && !self.current_limit.safe?
      config.retry.times do |now|
        begin
          timeout(config.timeout) do
            return @rubytter.__send__(method, *args, &block)
          end
        rescue Rubytter::APIError => e
          if /Status is over 140 characters/ =~ e.message
            len = args[0].charsize
            e2 = Rubytter::APIError.new("#{e.message} (+#{len - 140})")
            e2.set_backtrace(e.backtrace)
            raise e2
          else
            raise
          end
        rescue JSON::ParserError => e
          if message = error_html_message(e)
            puts message
            raise Rubytter::APIError.new(message)
          else
            raise e
          end
        rescue StandardError, TimeoutError => e
          if now + 1 == config.retry
            raise e
          else
            Termtter::Client.logger.debug { "rubytter_proxy: retry (#{e.class.to_s}: #{e.message})" }
          end
        end
      end
    end

    if defined? Nokogiri
      def error_html_message(e)
        Nokogiri(e.message).at('title, h2').text rescue nil
      end
    else
      def error_html_message(e)
        m = %r'<title>(.*?)</title>'.match(e.message) and m.captures[0] rescue nil
      end
    end
    private :error_html_message

    # XXX: these methods should be in oauth_rubytter
    def access_token
      @rubytter.instance_variable_get(:@access_token)
    end

    def consumer_token
      access_token.consumer
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
        threshold =
          [(Time.parse(limit.reset_time) - Time.now) / 3600 - 0.1, 0.1].max *
          limit.hourly_limit
        threshold < limit.remaining_hits
      end
    end
  end
end
