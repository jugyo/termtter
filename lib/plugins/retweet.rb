# -*- coding: utf-8 -*-

config.plugins.retweet.set_default(:format, 'RT @<%=s.user.screen_name%>: <%=s.text%>')

module Termtter::Client
  def self.post_retweet(s)
    text = ERB.new(config.plugins.retweet.format).result(binding)
    Termtter::API.twitter.update(text)
    puts "=> #{text}"
  end

  register_command(
    :name      => :retweet,
    :aliases   => [:rt],
    :help      => ['retweet,rt (TYPABLE|ID|@USER)', 'Post a retweet message'],
    :exec_proc => lambda {|arg|
      if public_storage[:typable_id] && s = typable_id_status(arg)
        post_retweet(s)
      else
        case arg
        when /(\d+)/
          post_retweet(Termtter::API.twitter.show(arg))
        when /@([A-Za-z0-9_]+)/
          user = $1
          statuses = Termtter::API.twitter.user_timeline(user)
          return if statuses.empty?
          post_retweet(statuses[0])
        end
      end
    },
    :completion_proc => lambda {|cmd, arg|
      if public_storage[:typable_id] && s = typable_id_status(arg)
        "u #{ERB.new(config.plugins.retweet.format).result(binding)}"
      else
        case arg
        when /@(.*)/
          find_user_candidates $1, "#{cmd} @%s"
        when /(\d+)/
          find_status_ids(arg).map{|id| "#{cmd} #{$1}"}
        end
      end
    }
  )
end
