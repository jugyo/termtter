module Termtter
  class RubytterProxy
    include Hookable

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

          success = false
          config.retry.times.each do
            begin
              timeout(config.timeout) do
                result = @rubytter.__send__(method, *modified_args)
              end
              success = true
              break
            rescue TimeoutError
            end
          end
          raise TimeoutError, 'execution expired' unless success

          self.class.call_hooks("post_#{method}", *args)
        rescue HookCanceled
        end
        result
      else
        super
      end
    end
  end
end
