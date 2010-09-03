# -*- coding: utf-8 -*-

unless [].respond_to?(:take)
  class Array
    def take(n) self[0...n] end
  end
end

unless :to_proc.respond_to?(:to_proc)
  class Symbol
    def to_proc
      Proc.new { |*args| args.shift.__send__(self, *args) }
    end
  end
end

unless :size.respond_to?(:size)
  class Symbol
    def size
      self.to_s.size
    end
  end
end
