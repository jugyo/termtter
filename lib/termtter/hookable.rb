# -*- coding: utf-8 -*-

if RUBY_VERSION <= '1.8.6'
  class String
    def each_char; split(//); end
  end
end

module Termtter
  class HookCanceled < StandardError; end

  module Hookable
    def self.included(base)
      base.class_eval do
        @hooks = {}

        class << self
          attr_reader :hooks

          def register_hook(arg, opts = {}, &block)
            hook = case arg
              when Hook
                arg
              when Hash
                Hook.new(arg)
              when String, Symbol
                options = { :name => arg }
                options.merge!(opts)
                options[:exec_proc] = block
                Hook.new(options)
              else
                raise ArgumentError, 'must be given Termtter::Hook, Hash, String or Symbol'
              end
            hooks[hook.name] = hook
          end

          def remove_hook(name)
            hooks.delete(name.to_sym)
          end

          def get_hook(name)
            hooks[name]
          end

          def get_hooks(point)
            # TODO: sort by alphabet
            hooks.values.select do |hook|
              hook.match?(point)
            end
          end

          # return last hook return value
          def call_hooks(point, *args)
            Termtter::Client.logger.debug "call_hooks: [:point => #{point}, :args => [#{args.map {|a| a.inspect.each_char.take(11).join}.join(', ')}]]"
            result = nil
            get_hooks(point).each {|hook|
              break if result == false # interrupt if hook return false
              Termtter::Client.logger.debug "call_hooks: #{point} #{hook.inspect}"
              result = hook.call(*args)
            }
            Termtter::Client.logger.debug "call_hooks: [:point => #{point}, :args => [#{args.map {|a| a.inspect.each_char.take(11).join}.join(', ')}]], done"
            result
          end

          def clear_hooks
            hooks.clear
          end
        end
      end
    end
  end
end
