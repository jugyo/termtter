# -*- coding: utf-8 -*-
module Termtter::Client
  register_command(
    :name => :diff_follow, :aliases => [:diff],
    :exec_proc => lambda {|arg|
      user_name = arg.empty? ? config.user_name : arg
      puts "getting friends"
      friends = get_friends(user_name, 2000).map(&:screen_name)
      puts "getting followers"
      followers = get_followers(user_name, 2000).map(&:screen_name)
      puts
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
