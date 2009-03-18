# -*- coding: utf-8 -*-

module Termtter
  class Hook
    attr_accessor :name, :points, :exec_proc

    def initialize(args)
      raise ArgumentError, ":name is not given." unless args.has_key?(:name)
      @name = args[:name].to_sym
      @points = args[:points] ? args[:points].map {|i| i } : []
      @exec_proc = args[:exec_proc] || lambda {}
    end

    def match?(point)
      !points.select{|pt|
        case pt
        when String, Symbol
          pt.to_s == point.to_s
        when Regexp
          (pt =~ point.to_s) ? true : false
        else
          false
        end
      }.empty?
    end

    # TODO: need spec
    def execute(*args)
      self.exec_proc.call(*args)
    end
  end
end
