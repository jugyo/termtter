# -*- coding: utf-8 -*-

config.plugins.retweet.set_default(
  :format, '<%= comment %><%= rt_or_qt %> @<%=s.user.screen_name%>: <%=s.text%>')
config.plugins.retweet.set_default(
  :confirm_protected, true)
config.plugins.retweet.set_default(
  :official_retweet, true)
config.plugins.retweet.set_default(
  :quotetweet, false)
config.plugins.retweet.set_default(
  :as_reply, false)

module Termtter::Client
  def self.post_retweet(s, comment = nil)
    s[:user][:protected] and
      config.plugins.retweet.confirm_protected and
      !confirm("#{s.user.screen_name} is protected! Are you sure?", false) and
      return

    # NOTE: If it's possible, this plugin tries to
    #   use the default RT feature twitter provides.
    if comment.nil? && config.plugins.retweet.official_retweet
      begin
        Termtter::API.twitter.retweet(s.id)
        # TODO: Vimshell support
        puts TermColor.parse("<blue>=&gt; RT @#{s.user.screen_name}: #{s.text}</blue>")
        return
      rescue Rubytter::APIError  # XXX: just for transition period
        if $!.to_s == 'Not found'
          Termtter::Client.logger.warn "Failed official retweet. Set twitter langage to English in https://twitter.com/account/settings or set config.plugins.retweet.official_retweet to false."
        else
          raise
        end
      end
    end
    comment += ' ' unless comment.nil?
    rt_or_qt = (config.plugins.retweet.quotetweet and comment) ? 'QT' : 'RT'
    text = ERB.new(config.plugins.retweet.format).result(binding)
    params = config.plugins.retweet.as_reply ? {:in_reply_to_status_id => s.id} : {}
    Termtter::API.twitter.update(text, params)
    puts "=> #{text}"
  end

  register_command(
    :name  => :retweet,
    :alias => :rt,
    :help  => ['retweet,rt (ID|@USER)', 'Post a retweet message'],
    :exec  => lambda {|arg|
      arg, comment = arg.split(/\s/, 2)

      case arg
      when /(\d+)/
        post_retweet(Termtter::API.twitter.show(arg), comment)
      when /@([A-Za-z0-9_]+)/
        user = $1
        statuses = Termtter::API.twitter.user_timeline(:screen_name => user)
        return if statuses.empty?
        post_retweet(statuses[0], comment)
      end
    }
  )

  register_command(
    :name => :retweets,
    :help => ['retweets ID', 'Show retweets of a tweet'],
    :exec => lambda {|arg|
      statuses = Termtter::API.twitter.retweets(arg)
      output(statuses, :retweets)
    }
  )

  register_command(
    :name => :retweeted_by_me,
    :help => ['retweeted_by_me', 'Show retweets posted by you.'],
    :exec => lambda {|arg|
      statuses = Termtter::API.twitter.retweeted_by_me(:include_entities => 1)
      output(statuses, :retweeted_by_me)
    }
  )

  register_command(
    :name => :retweeted_to_me,
    :help => ['retweeted_to_me', 'Show retweets posted by friends.'],
    :exec => lambda {|arg|
      statuses = Termtter::API.twitter.retweeted_to_me(:include_entities => 1)
      output(statuses, :retweeted_to_me)
    }
  )

  register_command(
    :name => :retweets_of_me,
    :help => ['retweets_of_me',
      'Show tweets of you that have been retweeted by others.'],
    :exec => lambda {|arg|
      statuses = Termtter::API.twitter.retweets_of_me(:include_entities => 1)
      output(statuses, :retweets_of_me)
    }
  )
end
