module Termtter
  class Task
    attr_accessor :name, :exec_at, :exec_proc, :interval
    def initialize(args = {}, &block)
      @name = args[:name]
      @exec_at = Time.now + (args[:after] || 0)
      @interval = args[:interval]
      @exec_proc = block || proc {}
    end
    def execute
      exec_proc.call
    end
  end
end
