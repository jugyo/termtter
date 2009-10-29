# -*- coding: utf-8 -*-

config.plugins.retweet.set_default(:format, '<%= comment %>RT @<%=s.user.screen_name%>: <%=s.text%>')
config.plugins.retweet.set_default(:confirm_protected, true)

module Termtter::Client
  def self.post_retweet(s, comment = nil)
    if s.user.protected && config.plugins.retweet.confirm_protected &&
        !confirm("#{s.user.screen_name} is protected! Are you sure?", false)
      return
    end

    comment += ' ' unless comment.nil?
    text = ERB.new(config.plugins.retweet.format).result(binding)
    Termtter::API.twitter.update(text)
    puts "=> #{text}"

    return text
  end

  register_command(
    :name      => :retweet,
    :aliases   => [:rt],
    :help      => ['retweet,rt (ID|@USER)', 'Post a retweet message'],
    :exec_proc => lambda {|arg|
      arg, comment = arg.split(/\s/, 2)
      txt = if public_storage[:typable_id] && s = typable_id_status(arg)
              post_retweet(s, comment)
            else
              case arg
              when /(\d+)/
                post_retweet(Termtter::API.twitter.show(arg), comment)
              when /@([A-Za-z0-9_]+)/
                user = $1
                statuses = Termtter::API.twitter.user_timeline(user)
                return if statuses.empty?
                post_retweet(statuses[0], comment)
              end
            end

      return txt
    }
  )
end
