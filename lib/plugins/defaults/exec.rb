# -*- coding: utf-8 -*-

module Termtter::Client
  register_command(
    :name => :exec,
    :alias => :'!',
    :exec_proc => lambda{|arg|
      system *arg.split(/\s+/) if arg
    },
    :help => ['exec SHELL_COMMAND', 'execute a shell command']
  )
end
