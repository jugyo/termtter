# -*- coding: utf-8 -*-

Termtter::Client.register_hook(
  :name => :confirm,
  :points => [:pre_exec_update],
  :exec_proc => lambda {|cmd, arg|
    if /^y?$/i !~ Readline.readline("update? #{arg} [Y/n] ", false)
      puts 'canceled.'
      raise Termtter::CommandCanceled
    end
  }
)
