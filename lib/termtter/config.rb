# -*- coding: utf-8 -*-
#
module Termtter
  class Config
    instance_methods.reject {|i| /__/ =~ i }.each do |f|
      undef_method f
    end

    def initialize
      @store = {}
    end

    # set_default :: (Symbol | String) -> a -> IO ()
    def set_default(name, value)
      match_p, init, last = *name.to_s.match(/^(.*?)\.([^\.]+)$/)
      if match_p
        eval(init).__assign__(last.intern, value)
      else
        __assign__(name, value)
      end
    end

    def method_missing(name, *args)
      case name.to_s
      when /(.*?)=$/
        raise NoMethodError if args.size != 1
        __assign__($1.intern, args.first)
      else
        raise NoMethodError unless args.empty?
        __refer__(name)
      end
    end

    # __assign__ :: Symbol -> a -> IO ()
    def __assign__(name, value)
      @store[name] = value
    end

    # __refer__ :: Symbol -> IO a
    def __refer__(name)
      @store[name] ||= Termtter::Config.new
    end

    def self.instance
      @@instance ||= new
    end
  end
end

def config
  Termtter::Config.instance
end

def configatron
  # remove this method until Termtter-1.2.0
  warn "configatron method will be removed. Use config instead. (#{caller.first})"
  Termtter::Config.instance
end
