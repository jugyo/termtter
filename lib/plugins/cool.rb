# -*- coding: utf-8 -*-

module Termtter::Client
  register_macro(:cool, "update @%s cool.",
    :help => ['cool {SCREENNAME}', 'update "@{SCREENNAME} cool."'],
    :completion_proc => lambda {|cmd, args|
      find_user_candidates args, "#{cmd} %s"
    }
  )
end
