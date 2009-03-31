# -*- coding: utf-8 -*-
module Termtter::Client
  register_command(
                   :name => :direct_messages,
                   :aliases => [:ds],
                   :exec_proc => lambda {|arg|
                     event = :list_user_timeline
                     ds = Termtter::API.twitter.direct_messages
                     DM = Struct.new :id, :text, :user, :created_at, :in_reply_to_status_id
                     statuses = ds.map do |d|
                       DM.new(d.id, d.text, d.sender, d.created_at)
                     end
                     output(statuses, event)
                   },
                   :completion_proc => lambda {|cmd, arg|
                   },
                   :help => ['direct_messages,ds', 'List direct messages for you'],
  )

  register_command(
                   :name => :sent_direct_messages,
                   :aliases => [:sds],
                   :exec_proc => lambda {|arg|
                     event = :list_user_timeline
                     ds = Termtter::API.twitter.sent_direct_messages
                     DM = Struct.new :id, :text, :user, :created_at, :in_reply_to_status_id
                     statuses = ds.map do |d|
                       DM.new(d.id, "@#{d.recipient.screen_name} #{d.text}", d.sender,  d.created_at)
                     end
                     output(statuses, event)
                   },
                   :completion_proc => lambda {|cmd, arg|
                   },
                   :help => ['sent_direct_messages, sds', 'List direct messages from you'],
                   )
end
