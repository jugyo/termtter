# -*- coding: utf-8 -*-
require 'im-kayac'
require 'cgi'

config.plugins.im_kayac.set_default(:user_name, nil)

Termtter::Client.register_hook(
  :name => :im_kayac,
  :point => :output,
  :exec => lambda { |statuses, event|
    return unless event == :update_friends_timeline

    user_name = config.plugins.im_kayac.user_name || config.user_name
    replies = statuses.select{|s| s.text.include?(user_name) }
    return if replies.empty?
    replies.each{|s|
      time = Time.parse(s.created_at).strftime(config.plugins.stdout.time_format_not_today)
      text = CGI.unescapeHTML(s.text).gsub('&', '＆') # XXX
      ImKayac.post(user_name, "#{s.user.screen_name}: #{text}\n#{time}")
    }
  })

# im_kayac.rb - notify replies via im.kayac
#
# This plugin requires gem im-kayac.
# This plugin does not support handler, password or sig.
