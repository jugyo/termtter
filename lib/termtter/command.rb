# -*- coding: utf-8 -*-

module Termtter

  class Command

    attr_accessor :name, :aliases, :exec_proc, :completion_proc, :help

    # args
    #   name:            Symbol as command name
    #   aliases:         Array of command alias (ex. ['u', 'up'])
    #   exec_proc:       Proc for procedure of the command. If need the proc must return object for hook.
    #   completion_proc: Proc for input completion. The proc must return Array of candidates (Optional)
    #   help:            help text for the command (Optional)
    def initialize(args)
      raise ArgumentError, ":name is not given." unless args.has_key?(:name)
      config = {
        :aliases        => [],
        :exec_proc      => lambda {|arg| },
        :comletion_proc => lambda {|command, arg| [] }
      }.merge(args)

      set config
    end

    def set(config)
      @name            = config[:name].to_sym
      @aliases         = config[:aliases].map {|e| e.to_sym }
      @exec_proc       = config[:exec_proc]
      @completion_proc = config[:completion_proc]
      @help            = config[:help]
    end

    def complement(input)
      command_info = match?(input)
      if command_info
        if completion_proc
          [completion_proc.call(command_info[0], command_info[1] || '')].flatten.compact
        else
          []
        end
      else
        [name.to_s, aliases.to_s].grep(/^#{Regexp.quote(input)}/)
      end
    end

    # MEMO: Termtter:Client からはこのメソッドを呼び出すことになると思う。
    def exec_if_match(input)
      command_info = match?(input)
      if command_info
        result = execute(command_info[1])
        unless result.nil?
          return result
        else
          return true
        end
      else
        return nil
      end
    end

    def execute(arg)
      arg = case arg
        when nil
          ''
        when String
          arg
        else
          raise ArgumentError, 'arg should be String or nil'
        end
      exec_proc.call(arg)
    end

    # return array like [command, arg]
    def match?(input)
      if pattern =~ input
        [$2 || $3, $4]  # $2 or $3 => command, $4 => argument
      else
        nil
      end
    end

    def pattern
      commands_regex = commands.map {|name| Regexp.quote(name.to_s) }.join('|')
      /^((#{commands_regex})|(#{commands_regex})\s+(.*?))\s*$/
    end

    def commands
      [name] + aliases
    end
  end
end

