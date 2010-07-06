# -*- coding: utf-8 -*-
#
require 'set'

module Termtter
  class Config
    def initialize
      @store = Hash.new(:undefined)
      @freezes = Set.new
    end

    def inspect
      @store.inspect
    end

    # call-seq:
    #   set_default :: (Symbol | String) -> a -> IO ()
    def set_default(name, value)
      match_p, init, last = *name.to_s.match(/^(.+)\.([^\.]+)$/)
      if match_p
        tmp = eval(init)
        if tmp.__refer__(last.to_sym).empty?
          tmp.__assign__(last.to_sym, value)
        end
      else
        current_value = __refer__(name.to_sym)
        if current_value.kind_of?(self.class) && current_value.empty?
          __assign__(name.to_sym, value)
        end
      end
    end

    # call-seq:
    #   empty? :: Boolean
    def empty?
      @store.empty?
    end

    def method_missing(name, *args)
      case name.to_s
      when /(.*)=$/
        __assign__($1.to_sym, args.first)
      else
        __refer__(name.to_sym)
      end
    end

    def __freeze__(name)
      @freezes << name.to_sym
    end

    def __unfreeze__(name)
      @freezes.delete(name.to_sym)
    end

    # call-seq:
    #   __assign__ :: Symbol -> a -> IO ()
    def __assign__(name, value)
      return if @freezes.include?(name)
      @store[name] = value
    end

    # call-seq:
    #   __refer__ :: Symbol -> IO a
    def __refer__(name)
      @store[name] == :undefined ? @store[name] = Termtter::Config.new : @store[name]
    end

    def __values__
      @store.dup
    end

    def __clear__(name = nil)
      return if name && @freezes.include?(name)
      if name
        @store[name] = :undefined
      else
        @store.clear
      end
    end

    __instance = self.new
    (class << self; self end).
      __send__(:define_method, :instance) { __instance }
  end
end

def config
  Termtter::Config.instance
end

