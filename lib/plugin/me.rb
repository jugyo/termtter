# -*- coding: utf-8 -*-
module Termtter::Client
  register_command(
    :name => :me, :aliases => [],
    :exec_proc => lambda {|arg|
      myname = configatron.user_name
      call_hooks(Termtter::API.twitter.get_user_timeline(myname), :list_user_timeline)
    },
    :help => ['me', 'show my timeline']
  )
end
