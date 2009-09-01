# -*- coding: utf-8 -*-
module Termtter::Client
  register_command(
    :name => :me, :aliases => [],
    :exec_proc => lambda {|arg|
      call_commands('list ' + config.user_name)
    },
    :help => ['me', 'show my timeline']
  )
end
