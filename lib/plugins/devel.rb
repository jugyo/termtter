# -*- coding: utf-8 -*-

module Termtter::Client
  register_command(
   :name => :eval,
   :aliases => [],
   :exec_proc => lambda {|arg|
     result = eval(arg) unless arg.empty?
     puts "=> #{result.inspect}"
   },
   :help => ['eval EXPR', 'evaluate expression']
  )
end
