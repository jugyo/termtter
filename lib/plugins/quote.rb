# -*- coding: utf-8 -*-

config.plugins.quote.set_default(:format, '<%= comment %>QT @<%=s.user.screen_name%>: <%=s.text%>')
config.plugins.quote.set_default(:confirm_protected, true)

module Termtter::Client
  def self.post_quote(s, comment = nil)
    if s.user.protected && config.plugins.quote.confirm_protected &&
        !confirm("#{s.user.screen_name} is protected! Are you sure?", false)
      return
    end

    comment += ' ' unless comment.nil?
    text = ERB.new(config.plugins.quote.format).result(binding)
    Termtter::API.twitter.update(text)
    puts "=> #{text}"

    return text
  end

  register_command(
    :name      => :quote,
    :aliases   => [:qt],
    :help      => ['quote,qt (ID|@USER)', 'Post a quote message'],
    :exec_proc => lambda {|arg|
      arg, comment = arg.split(/\s/, 2)

      if public_storage[:typable_id] && s = typable_id_status(arg)
        post_quote(s, comment)
      else
        case arg
        when /(\d+)/
          post_quote(Termtter::API.twitter.show(arg), comment)
        when /@([A-Za-z0-9_]+)/
          user = $1
          statuses = Termtter::API.twitter.user_timeline(:screen_name => user)
          return if statuses.empty?
          post_quote(statuses[0], comment)
        end
      end
    }
  )
end
