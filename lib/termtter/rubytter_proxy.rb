module Termtter
  class RubytterProxy
    include Hookable

    def initialize(*args)
      @rubytter = Rubytter.new(*args)
    end

    def method_missing(method, *args, &block)
      if @rubytter.methods.include?(method.to_s)
        result = nil
        begin
          self.class.call_hooks("pre_#{method}", *args)
          result = @rubytter.__send__(method, *args, &block)
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
