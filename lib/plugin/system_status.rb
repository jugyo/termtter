require 'erb'

configatron.plugins.termtter_status.set_default(:interval, 1)
configatron.plugins.termtter_status.set_default(:default_color, :on_blue)
configatron.plugins.termtter_status.set_default(:format, '<%= status %>')

module Termtter::Client
  Thread.new do
    loop do
      status = public_storage[:system_status] || 
                  Time.now.strftime("%x %X")
      formatted_status = ERB.new(configatron.plugins.termtter_status.format).result(binding)
      color = public_storage[:system_status_color] || 
                      configatron.plugins.termtter_status.default_color
      colored_status = color(formatted_status, color)
      print "\e[s\e[1000G\e[#{status.size - 1}D#{colored_status}\e[u"
      $stdout.flush
      sleep configatron.plugins.termtter_status.interval
    end
  end
end

# system_status.rb
#   show system status on left side.
#   output public_storage[:system_status] or Time.now.strftime("%x %X") if nil
# example config
#   configatron.plugins.termtter_status.interval = 1
#   configatron.plugins.termtter_status.default_color = :on_blue
#   configatron.plugins.termtter_status.format = '<%= status %>'

