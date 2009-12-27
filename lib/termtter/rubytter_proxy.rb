module Termtter
  class RubytterProxy
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

          result = call_rubytter(method, *modified_args, &block)

          self.class.call_hooks("post_#{method}", *args)
        rescue HookCanceled
        end
        result
      else
        super
      end
    end

    def call_rubytter(method, *args, &block)
      config.retry.times do
        begin
          timeout(config.timeout) do
            return @rubytter.__send__(method, *args, &block)
          end
        rescue TimeoutError
        end
      end
      raise TimeoutError, 'execution expired'
    end
  end
end
