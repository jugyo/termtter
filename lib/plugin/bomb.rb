module Termtter
  class Status
    def bomb?
      self.text =~ /爆発/
    end
  end
end

# bomb.rb
# See http://gyazo.com/4b33517380673d92f51a52e675ecdb02.png .
#
# configatron.plugins.stdout.timeline_format =
#  '<%= color(time, 90) %> <%= s.bomb? ? color(color(status, 41), 37) : color(status, status_color) %> <%= color(id, 90) %>'

