# -*- coding: utf-8 -*-

module Termtter
  class Status
    def bomb?
      /爆発|bomb/ =~ self.text
    end
  end

  module Client
    register_command(
      :name => :bomb, :aliases => [],
      :exec_proc => lambda {|arg|
        text = "#{arg.strip} 爆発しろ!"
        Termtter::API::twitter.update_status(text)
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
# config.plugins.stdout.timeline_format =
#   %q[<90><%=time%></90> <%= s.bomb? ? "<37><41>#{status}</41></37>" : "<#{status_color}>#{status}</#{status_color}>" %> <90><%=id%></90>]
# vim: fenc=utf8
