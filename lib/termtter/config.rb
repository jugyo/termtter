# -*- coding: utf-8 -*-

def configatron; Termtter::Config.instance end

module Termtter
  module Config
    class Storage
      def initialize(name, value = nil, parent = nil)
        @_name = (parent ? "#{parent}." : '') + name
        @_value = value
      end

      def method_missing(sym, *args)
        method(sym).call
      rescue
        name = sym.to_s.gsub(/(=)\z/, '')
        value = $1 ? args.shift : nil
        child = self.class.new(name, value, @_name)
        metaclass.__send__(:define_method, name) { value ? value : child }
        child
      end

      def set_default(name, value)
        method(name)
      rescue
        instance_variable_set("@#{name.to_s}", value)
        metaclass.__send__(:attr_reader, name.to_sym)
      ensure
        nil
      end

      def inspect; "#{@_name}" end
      def nil?; @_value.nil? end

      def metaclass; class << self; self end end
      private :metaclass
    end

    class << self
      _instance = Storage.new('config')
      define_method(:instance) { _instance }
    end
  end
end
