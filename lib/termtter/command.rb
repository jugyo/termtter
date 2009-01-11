module Termtter
  class Command

    attr_accessor :names, :pattern, :exec, :completion, :help

    # args
    #   names:      String or Array (ex. ['update', 'u'])
    #   pattern:    Regex for pattern of the command
    #   exec:       Proc for procedure of the command. If need the proc must return object for hook.
    #   completion: Proc for input completion. The proc must return Array of candidates (Optional)
    #   help:       help text for the command (Optional)
    def initialize(args)
      @names = [args[:names]].flatten
      @pattern = args[:pattern]
      @exec = args[:exec]
      @completion = args[:completion]
      @help = args[:help]
    end

    def complement(input)
      completion.call(input)
    end

    def exec_if_match(input)
      if input =~ pattern
        exec.call($~)
      end
    end
  end
end

