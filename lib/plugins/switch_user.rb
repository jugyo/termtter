# -*- coding: utf-8 -*-

module Termtter::Client
  register_command(
    :name => :switch_user,
    :exec_proc => lambda {|arg|
      Termtter::API.switch_user(arg)
    },
    :completion_proc => lambda {|cmd, arg|
      # TODO
    },
    :help => ["switch_user USERNAME", "Switch twitter account."]
  )

  register_command(
    :name => :restore_user,
    :exec_proc => lambda {|arg|
      Termtter::API.restore_user
    },
    :help => ["restore_user", "Restore default twitter account."]
  )
end
