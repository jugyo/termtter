# -*- coding: utf-8 -*-

Termtter::Client.register_hook(

  :name => :modify_arg_hook_sample,

  :points => [:modify_arg_for_update],

  :exec_proc => proc {|cmd, arg| arg + '＼(＾o＾)／'}

)
