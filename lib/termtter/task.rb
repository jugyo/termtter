# -*- coding: utf-8 -*-

module Termtter
  class Task
    attr_accessor :name, :exec_at, :exec_proc, :interval, :work
    def initialize(args = {}, &block)
      @name      = args[:name]
      @exec_at   = Time.now + (args[:after] || 0)
      @interval  = args[:interval]
      @exec_proc = block || lambda {}
      @work      = true
    end
    def execute
      exec_proc.call(self) if work
    end
  end
end
