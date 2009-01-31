# -*- coding: utf-8 -*-

Termtter::Client.register_hook(

  :name => :confirm,

  :points => [:pre_exec_update],

  :exec_proc => proc {|cmd, arg|

    false if arg.empty? || /^y?$/i !~ Readline.readline("update? #{arg} [Y/n] ", false)

  }

)
