# -*- coding: utf-8 -*-

config.plugins.reply_retweet.set_default(:format, '<%= comment %>RT @<%=s.user.screen_name%>: <%=text%>')
config.plugins.reply_retweet.set_default(:confirm_protected, true)

module Termtter::Client
  def self.post_reply_retweet(s, comment = nil)
    if s.user.protected && config.plugins.reply_retweet.confirm_protected &&
        !confirm("#{s.user.screen_name} is protected! Are you sure?", false)
      return
    end

    text = s.text.gsub(/RT.+\z/, '')
    comment += ' ' unless comment.nil?
    text = ERB.new(config.plugins.reply_retweet.format).result(binding)
    Termtter::API.twitter.update(text)
    puts "=> #{text}"

    return text
  end

  help = ['reply_retweet,rrt (ID|@USER)', 'Post a reply retweet message'],
  register_command(:reply_retweet, :help => help, :alias => :rrt) do |arg|

    arg, comment = arg.split(/\s/, 2)

    if public_storage[:typable_id] && s = typable_id_status(arg)
      post_reply_retweet(s, comment)
    else
      case arg
      when /(\d+)/
        post_reply_retweet(Termtter::API.twitter.show(arg), comment)
      when /@([A-Za-z0-9_]+)/
        user = $1
        statuses = Termtter::API.twitter.user_timeline(:screen_name => user)
        return if statuses.empty?
        post_reply_retweet(statuses[0], comment)
      end
    end
  end
end

