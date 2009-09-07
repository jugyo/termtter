# -*- coding: utf-8 -*-
require 'enumerator'

module Termtter
  module Client
    config.plugins.bomb.set_default :format, "<on_red><white>%s</white></on_red>"

    register_hook(
      :name => :bomb,
      :points => [:output],
      :exec_proc => lambda{|statuses, event|
        statuses.each do |status|
          if /爆発|bomb/ =~ status.text
            status.text = config.plugins.bomb.format % status.text
          end
        end
      }
    )

    register_command(
      :name => :bomb, :aliases => [],
      :exec_proc => lambda {|arg|
        text = "#{arg.strip} 爆発しろ!"
        Termtter::API::twitter.update(text)
        puts "=> #{text}"
      },
      :help => ['bomb WORD', 'Bomb it']
    )
  end
end

# bomb.rb
# Bomb it!
#
# See http://gyazo.com/4b33517380673d92f51a52e675ecdb02.png .
# config.plugins.bomb.color.foreground = 'white'
# config.plugins.bomb.color.background = 'red'
#
# vim: fenc=utf8
