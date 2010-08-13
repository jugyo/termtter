# -*- coding: utf-8 -*-

module Termtter
  class Command
    attr_accessor :name, :aliases, :author, :exec_proc, :completion_proc, :help

    # args
    #   name:            (required) Symbol as command name
    #   aliases:         Array of command alias (ex. ['u', 'up'])
    #   exec_proc:       Proc for procedure of the command. If need the proc must return object for hook.
    #   completion_proc: Proc for input completion. The proc must return Array of candidates (Optional)
    #   help:            Help text for the command (Optional)
    #   author:          The author's name (Optional)
    def initialize(args)
      raise ArgumentError, ":name is not given." unless args.has_key?(:name)
      args = args.dup
      args[:exec_proc] ||= args[:exec]
      args[:completion_proc] ||= args[:completion]
      args[:aliases] ||= [args[:alias]].compact

      cfg = {
        :aliases => [],
        :exec_proc => lambda {|arg| },
        :comletion_proc => lambda {|command, arg| [] },
        :author => 'ujihisa',
      }.merge(args) {|k, v1, v2| v2 ? v2 : v1 }

      set cfg
    end

    # call-seq:
    #   set :: Hash -> ()
    def set(cfg)
      self.name             = cfg[:name].to_sym
      self.aliases          = cfg[:aliases]
      self.exec_proc        = cfg[:exec_proc]
      self.completion_proc  = cfg[:completion_proc]
      self.help             = cfg[:help]
      self.author           = cfg[:author]
    end

    # call-seq:
    #   complement :: String -> [String]
    def complement(input)
      input = input.sub(/^\s*/, '')
      if match?(input) && input =~ /^[^\s]+\s/
        if completion_proc
          command_str, command_arg = split_command_line(input)
          [completion_proc.call(command_str, command_arg || '')].flatten.compact
        else
          []
        end
      else
        []
      end
    end

    # call-seq:
    #   call :: ???
    def call(cmd = nil, arg = nil, original_text = nil)
      from = Time.now
      arg = case arg
        when nil
          ''
        when String
          arg
        else
          raise ArgumentError, 'arg should be String or nil'
        end
      Termtter::Client.logger.debug { "command: #{cmd} #{arg}" }
      result = exec_proc.call(arg)
      Termtter::Client.logger.debug { "command: #{cmd} #{arg} #{'%.2fsec' % (Time.now - from)}" }
      result
    rescue => e
      Termtter::Client.logger.debug { "command: #{cmd} #{arg} #{e.message} #{'%.2fsec' % (Time.now - from)}" }
      raise e
    end

    # call-seq:
    #   match? :: String -> Boolean
    def match?(input)
      !!pattern.match(input)
    end

    # call-seq:
    #   pattern :: Regexp
    def pattern
      commands_regex = commands.map {|name| name.to_s.split(' ').map {|i| Regexp.quote(i)}.join('\s+') }.join('|')
      /^\s*((#{commands_regex})|(#{commands_regex})\s+(.*?))\s*$/
    end

    # call-seq:
    #   commands :: [Symbol]
    def commands
      [name] + aliases
    end

    def aliases=(as)
      @aliases = as.map { |a| a.to_sym }
    end

    # call-seq:
    #   alias= :: Symbol -> ()
    def alias=(a)
      self.aliases = [a]
    end

    # call-seq:
    #   author= :: String -> ()
    def author=(a)
      @author = a
    end

    def command_words
      name.to_s.split(/\s+/)
    end

    # call-seq:
    #   split_command_line :: String -> (String, String)
    def split_command_line(line)
      m = pattern.match(line)
      if m
        unless m[2].nil?
          [m[2], '']
        else
          [m[3], m[4]]
        end
      else
        []
      end
    end
  end
end
