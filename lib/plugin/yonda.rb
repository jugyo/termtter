# -*- coding: utf-8 -*-

module Termtter::Client

  public_storage[:unread_count] = 0



  add_help 'yonda,y', 'Mark as read'



  add_command %r'^y(?:onda)?\s*$' do |m, t|

    public_storage[:unread_count] = 0

    print "\033[2J\033[H" # FIXME

    call_hooks [], :plugin_yonda_yonda, t

  end



  add_hook do |statuses, event|

    case event

    when :update_friends_timeline

      public_storage[:unread_count] += statuses.size

    end

  end

end
