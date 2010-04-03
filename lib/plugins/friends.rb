# -*- coding: utf-8 -*-
module Termtter::Client
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
