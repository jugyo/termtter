# -*- coding: utf-8 -*-
module Termtter::Client

  class << self
    def get_friends(user_name, max)
      friends = []
      page = 0
      begin
        friends += tmp = Termtter::API::twitter.friends(user_name,
            :page => page += 1)
        puts "#{friends.length}/#{max}"
      rescue
      end until (tmp.empty? or friends.length > max)
      friends.take(max)
    end
  end

  register_command(
    :name => :friends, :aliases => [:following],
    :exec_proc => lambda {|arg|
      user_name = arg.empty? ? config.user_name : arg
      public_storage[:friends] = friends = get_friends(user_name, 2000)
      puts friends.map(&:screen_name).join(' ')
    },
    :help => ["friends,following [USERNAME]", "Show user's friends."]
  )

  register_command(
    :name => :diff_follow, :aliases => [:diff],
    :exec_proc => lambda {|arg|
      user_name = arg.empty? ? config.user_name : arg
      friends = public_storage[:friends]
      followers = public_storage[:followers]
      if friends.nil? || followers.nil?
        puts 'Do followers and friends first.'
        return
      end
      friends = friends.map(&:screen_name)
      followers = followers.map(&:screen_name)
      puts "friends - followers:"
      puts (friends - followers).map{|s|"http://#{config.host}/#{s}"}.join("\n")
      puts
      puts "followers - friends:"
      puts (followers - friends).map{|s|"http://#{config.host}/#{s}"}.join("\n")
    },
    :help => ["diff_follow,diff",
        "Show difference between frineds and followers."]
  )

end
