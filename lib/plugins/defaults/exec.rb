# -*- coding: utf-8 -*-

module Termtter::Client
  register_command(
    :name => :exec,
    :exec_proc => lambda{|arg|
      return unless arg
      begin
        pause
        system *arg.split(/\s+/)
      ensure
        resume
      end
    },
    :help => ['exec SHELL_COMMAND', 'execute a shell command']
  )
end
