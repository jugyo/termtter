# -*- coding: utf-8 -*-
module Termtter::Client
  class << self
    def delete_command(arg)
      if @commands.delete(arg.to_sym)
        puts "#{arg} command is deleted."
      else
        raise "#{arg} command is not found."
      end
    end

    def alias_command(arg)
      original, new = arg.split(/\s+/)
      if @commands[original.to_sym]
        @commands[new.to_sym] = @commands[original.to_sym].clone
        @commands[new.to_sym].name    = new.to_sym
        @commands[new.to_sym].aliases = []
        @commands[new.to_sym].help    = ''
        puts "alias '#{original}' to '#{new}'."
      else
        raise "#{original} command is not found."
      end
    end
  end
end

module Termtter::Client
  register_command(
    :name => :delete_command,
    :exec_proc => lambda {|arg|
    Termtter::Client.delete_command(arg)
  },
    :completion_proc => lambda {|cmd, arg|
  },
    :help => ['delete_command command', 'delete command from command list (this command is experimental!)']
  )

  register_command(
    :name => :alias_command,
    :exec_proc => lambda {|arg|
    Termtter::Client.alias_command(arg)
  },
    :completion_proc => lambda {|cmd, arg|
  },
    :help => ['alias_command A B', 'alias command A to B (this command is experimental!)']
  )
end
