module Termtter
  class Task
    attr_reader :exec_at, :exec_proc
    def initialize(args = {}, &block)
      @exec_at = Time.now + (args[:after] || 0)
      @exec_proc = block || proc {}
    end
  end
end
