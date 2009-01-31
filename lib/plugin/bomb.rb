module Termtter
  class Status
    def bomb?
      /爆発|bomb/ =~ self.text
    end
  end

  module Client
    register_command(
      :name => :bomb, :aliases => [],
      :exec_proc => proc {|arg|
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
# configatron.plugins.stdout.timeline_format =
#  '<%= color(time, 90) %> <%= s.bomb? ? color(color(status, 41), 37) : color(status, status_color) %> <%= color(id, 90) %>'
# vim: fenc=utf8
