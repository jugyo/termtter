module Termtter
  class Task
    attr_accessor :exec_at, :exec_proc, :interval
    def initialize(args = {}, &block)
      @exec_at = Time.now + (args[:after] || 0)
      @interval = args[:interval]
      @exec_proc = block || proc {}
    end
    def execute
      exec_proc.call
    end
  end
end
