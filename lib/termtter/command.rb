module Termtter
  class Command

    attr_accessor :name, :aliases, :exec_proc, :completion_proc, :help, :pattern

    # args
    #   name:       Command name
    #   aliases:    Array of command alias (ex. ['u', 'up'])
    #   exec:       Proc for procedure of the command. If need the proc must return object for hook.
    #   completion: Proc for input completion. The proc must return Array of candidates (Optional)
    #   help:       help text for the command (Optional)
    def initialize(args)
      @name = args[:name]
      @aliases = args[:aliases] || []
      @exec_proc = args[:exec]
      @completion_proc = args[:completion]
      @help = args[:help]
    end

    def complement(input)
      if command_info = match?(input)
        [completion_proc.call(command_info[0], command_info[1])].flatten.compact
      else
        [name]
      end
    end

    # MEMO: Termtter:Client からはこのメソッドを呼び出すことになると思う。
    def exec_if_match(input)
      command_info = match?(input)
      if command_info
        return execute(command_info[1])
      else
        return nil
      end
    end

    # return array like [command, arg]
    def match?(input)
     if input =~ pattern
        [$2 || $3, $4]  # $3 => command, $4 => argument
      else
        nil
      end
    end

    def pattern
      commands_regex = commands.map{|i|Regexp.quote(i)}.join('|')
      /^\s*((#{commands_regex})|(#{commands_regex})\s+(.*?))\s*$/
    end

    # When no arguments for the command you should give nil as method arguments
    def execute(arg)
      exec_proc.call(arg)
    end

    def commands
      aliases.unshift(name)
    end
  end
end

