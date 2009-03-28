# -*- coding: utf-8 -*-

Termtter::Client.register_command(
  :name => :execute,
  :exec_proc => lambda{|arg|
    return unless arg
    `#{arg}`.each_line do |line|
      next if line =~ /^\s*$/
      Termtter::API.twitter.update(line)
      puts "=> #{line}"
    end
  },
  :help => ['execute COMMAND', 'execute the command']
)
