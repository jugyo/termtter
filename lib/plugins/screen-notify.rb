# -*- coding: utf-8 -*-

config.screen_notify.set_default(:format, "[termtter] %s")

module Termtter::Client
  register_hook(
    :name => :screen_notify,
    :points => [:post_filter],
    :exec_proc => lambda{|statuses, event|
      return unless event = :update_friends_timeline
      Thread.new(statuses) do |ss|
        ss.each do |s|
          msg = config.screen_notify.format % s.user.screen_name
          system 'screen', '-X', 'eval', "bell_msg '#{msg}'", 'bell'
          sleep 1
        end
      end
    }
  )
end
