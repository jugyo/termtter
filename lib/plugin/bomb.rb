module Termtter
  class Status
    def bomb?
      self.text =~ /爆発/
    end
  end

  module Client
    add_help 'bomb WORD', 'Bomb it'
    add_command %r'^bomb\s+(.+)$' do |m, t|
      bomb = m[1]
      msg = "#{bomb} 爆発しろ!"

      puts msg
      t.update_status msg
    end
  end
end

# bomb.rb
# Bomb it!
#
# See http://gyazo.com/4b33517380673d92f51a52e675ecdb02.png .
# configatron.plugins.stdout.timeline_format =
#  '<%= color(time, 90) %> <%= s.bomb? ? color(color(status, 41), 37) : color(status, status_color) %> <%= color(id, 90) %>'

