# -*- coding: utf-8 -*-

require 'termtter/active_rubytter'

module Termtter
  class Event
    def initialize(name, params = {})
      raise TypeError unless name.kind_of? Symbol
      raise TypeError unless params.kind_of? Hash
      @name = name
      @params = ActiveRubytter.new(params)
    end

    attr_reader :name
    undef_method :to_s

    def method_missing(name, *args)
      @name.__send__(name, *args)
    rescue NoMethodError
      @params.__send__(name, *args)
    end

    def [](name)
      @params.__send__(:[], name)
    end

    def hash
      @name.hash
    end

    def has_key?(key)
      @params.to_hash.has_key?(key)
    end

    def set_param(key, value)
      data = @params.to_hash
      data[key] = value
      @params.attributes = data
      value
    end

    alias_method :[]=, :set_param

    def ==(b)
      self.eql?(b)
    end

    def eql?(b)
      if b.kind_of? Event
        @name == b.name
      else
        @name == b
      end
    end
    alias_method :===, :==
  end
end
__END__
class Symbol
  def eql?(b)
    if b.kind_of? Termtter::Event
      self.equal? b.name
    else
      self.equal? b
    end
  end
  alias_method :==,   :eql?
  alias_method :===,  :eql?
end
