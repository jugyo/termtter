# -*- coding: utf-8 -*-

require 'time'
require File.dirname(__FILE__) + '/storage/db'

module Termtter::Client
  @db = Termtter::Storage::DB.new
  register_hook(
    :name => :storage,
    :points => [:pre_filter],
    :exec_proc => lambda {|statuses, event|
      statuses.each do |s|
        @db.update(
          :post_id => s.id,
          :created_at => Time.parse(s.created_at).to_i,
          :in_reply_to_status_id => s.in_reply_to_status_id,
          :in_reply_to_user_id => s.in_reply_to_user_id,
          :text => s.text,
          :user_id => s.user.id,
          :screen_name => s.user.screen_name
        )
      end
    }
  )

  register_command(
    :name => :search_storage,
    :aliases => [:ss],
    :exec_proc => lambda {|arg|
      unless arg.strip.empty?
        text = arg.strip
        statuses = @db.find_text(text)
        output(statuses, :search)
      end
    },
    :help => [ 'search_storage WORD', 'Search storage for WORD' ]
  )

  register_command(
    :name => :search_storage_user,
    :aliases => [:ssu],
    :exec_proc => lambda {|arg|
      unless arg.strip.empty?
        user = arg.strip.gsub(/^@/, '')
        statuses = @db.find_user(user)
        output(statuses, :search)
      end
    },
    :help => [ 'search_storage_user SCREEN_NAME', 'Search storage for SCREE_NAME' ]
  )

end
