# -*- coding: utf-8 -*-

Termtter::Client.register_hook(

  :name => :pre_exec_hook_sample,

  :points => [:pre_exec_update],

  :exec_proc => proc {|cmd, arg|

    false if /^y?$/i !~ Readline.readline("update? #{arg} [Y/n] ", false)

  }

)
