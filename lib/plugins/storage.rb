# -*- coding: utf-8 -*-

require 'pp'
require 'time'

require File.dirname(__FILE__) + '/storage/status'

module Termtter::Client
  public_storage[:log] = []

  register_hook(
    :name => :storage,
    :points => [:pre_filter],
    :exec_proc => lambda {|statuses, event|
      statuses.each do |s|
        Termtter::Storage::Status.insert(
          :post_id => s.id,
          :created_at => Time.parse(s.created_at).to_i,
          :in_reply_to_status_id => s.in_reply_to_status_id,
          :in_reply_to_user_id => s.in_reply_to_user_id,
          :post => s.text,
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
        key = arg.strip
        statuses = Termtter::Storage::Status.search({:text => key})
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
        key = arg.strip
        statuses = Termtter::Storage::Status.search_user({:user => key})
        output(statuses, :search)
      end
    },
    :help => [ 'search_storage_user SCREEN_NAME', 'Search storage for SCREE_NAME' ]
  )

end
