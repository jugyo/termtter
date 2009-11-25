# -*- coding: utf-8 -*-

unless Array.instance_methods.include?('take')
  class Array
    def take(n) self[0...n] end
  end
end

unless Symbol.instance_methods.include?('to_proc')
  class Symbol
    def to_proc
      Proc.new { |*args| args.shift.__send__(self, *args) }
    end
  end
end

