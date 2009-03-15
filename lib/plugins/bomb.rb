# -*- coding: utf-8 -*-

module Termtter

  module Client
    config.plugins.bomb.color.set_default :foreground, 'white'
    config.plugins.bomb.color.set_default :background, 'red'

    add_hook do |statuses, event|
      case event
      when :post_filter
        fg = config.plugins.bomb.color.foreground
        bg = config.plugins.bomb.color.background
        statuses = [statuses] unless statuses.instance_of? Array
        statuses.each do |status|
          if /爆発|bomb/ =~ status.text
            status.text = "<on_#{bg}><#{fg}>#{status.text}</#{fg}></on_#{bg}>"
          end
        end
      end
    end

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
