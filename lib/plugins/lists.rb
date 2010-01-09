# -*- coding: utf-8 -*-
module Termtter::Client
  register_command(
    :name => :list, :aliases => [:l],
    :exec_proc => lambda {|arg|
      if arg =~ /\-([\d]+)/
        options = {:count => $1}
        arg = arg.gsub(/\-([\d]+)/, '')
      else
        options = {}
      end

      if arg.empty?
        event = :list_friends_timeline
        statuses = Termtter::API.twitter.friends_timeline(options)
      else
        event = :list_user_timeline
        statuses = []
        Array(arg.split).each do |user|
          if user =~ /\//
            user_name, slug = *user.split('/')
            user_name = normalize_as_user_name(user_name)
            statuses += Termtter::API.twitter.list_statuses(user_name, slug, options)
          else
            user_name = normalize_as_user_name(user)
            statuses += Termtter::API.twitter.user_timeline(user_name, options)
          end
        end
      end
      output(statuses, event)
    },
    :help => ["list,l [USERNAME]/[SLUG] [-COUNT]", "List the posts"]
  )
end
