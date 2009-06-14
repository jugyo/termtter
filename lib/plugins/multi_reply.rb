# -*- coding: utf-8 -*-

module Termtter::Client
  register_command(
    :name => :multi_reply, :aliases => [:mr],
    :exec_proc => lambda {|arg|
      text = ERB.new(arg).result(binding).gsub(/\n/, ' ')
      unless text.empty?
        /(@(.+))*\s+(.+)/ =~ text
        if $1
          msg = $3
          text = $1.split(/\s+/).map {|u| "#{u} #{msg}" }
        end
        Array(text).each do |post|
          Termtter::API.twitter.update(post)
          puts "=> #{post}"
        end
      end
    },
    :help => ["multi_reply,mp TEXT", "Reply to multi user"]
  )
end
