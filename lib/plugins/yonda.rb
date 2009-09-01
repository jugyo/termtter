# -*- coding: utf-8 -*-

module Termtter::Client
  register_command(:name => :yonda,
                   :aliases => [:y],
                   :exec_proc => lambda { |arg|
                     public_storage[:unread_count] = 0
                     print "\033[2J\033[H" # FIXME
                     true
                   },
                   :help => ['yonda,y', 'Mark as read']
  )

  register_hook(:name => :yonda,
                :points => [:post_exec__update_timeline],
                :exec_proc => lambda { |cmd, arg, result|
                  public_storage[:unread_count] ||= 0
                  public_storage[:unread_count]  += result.size
                }
  )
end
