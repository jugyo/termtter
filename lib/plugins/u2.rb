# -*- coding: utf-8 -*-

module Termtter::Client
  register_command(
    :name => :update2, :aliases => [:u2],
    :exec_proc => lambda {|arg|
      unless /^\s*$/ =~ arg
        id, status = arg.split(' ', 2)
        text = ERB.new(status).result(binding).gsub(/\n/, ' ')
        result = if id =~ /^\d+$/
                   Termtter::API.twitter.update(text, {'in_reply_to_status_id' => id})
                 else
                   Termtter::API.twitter.update(text)
                 end
        puts "=> #{text}"
        result
      end
    },
    :completion_proc => lambda {|cmd, args|
      #todo
    },
    :help => ["update2,u2 STATUS_ID TEXT", "Post a message to STATUS_ID"]
  )
end
