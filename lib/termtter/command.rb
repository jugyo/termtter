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
      args[:exec_proc] ||= args[:exec]
      args[:completion_proc] ||= args[:completion]
      args[:aliases] ||= [args[:alias]].compact

      cfg = {
        :aliases        => [],
        :exec_proc      => lambda {|arg| },
        :comletion_proc => lambda {|command, arg| [] }
      }.merge(args)

      set cfg
    end

    def set(cfg)
      @name            = cfg[:name].to_sym
      @aliases         = cfg[:aliases].map {|e| e.to_sym }
      @exec_proc       = cfg[:exec_proc]
      @completion_proc = cfg[:completion_proc]
      @help            = cfg[:help]
    end

    def complement(input)
      command_str, command_arg = match?(input)
      if command_arg
        if completion_proc
          [completion_proc.call(command_str, command_arg || '')].flatten.compact
        else
          []
        end
      else
        [name.to_s, aliases.to_s].grep(/^#{Regexp.quote(input)}/)
      end
    end

    def call(arg)
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
    # match? メソッドがなんかきもちわるいので変える予定
    def match?(input)
      if pattern =~ input
        [$2 || $3, $4]  # $2 or $3 => command, $4 => argument
      else
        [nil, nil]
      end
    end

    def pattern
      commands_regex = commands.map {|name| Regexp.quote(name.to_s) }.join('|')
      /^((#{commands_regex})|(#{commands_regex})\s+(.*?))\s*$/
    end

    def commands
      [name] + aliases
    end

    def self.split_command_line(line)
      line.strip.split(/\s+/, 2)
    end
  end
end

