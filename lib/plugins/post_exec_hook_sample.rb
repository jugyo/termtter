# -*- coding: utf-8 -*-

Termtter::Client.register_hook(
  :name => :post_exec_hook_sample,
  :points => [:post_exec_list],
  :exec_proc => lambda {|cmd, arg, result|
    p result
  }
)
