require 'erb'

configatron.plugins.termtter_status.set_default(:interval, 1)
configatron.plugins.termtter_status.set_default(:background, :on_blue)
configatron.plugins.termtter_status.set_default(:format, '<%= status %>')

module Termtter::Client
  Thread.new do
    loop do
      status = public_storage[:system_status] || Time.now.strftime("%x %X")
      status = ERB.new(configatron.plugins.termtter_status.format).result(binding)
      back = status.size - 1
      colored_status = color(status, configatron.plugins.termtter_status.background)
      print "\e[s\e[1000G\e[#{back}D#{colored_status}\e[u"
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
#   configatron.plugins.termtter_status.backgrond = :on_blue
#   configatron.plugins.termtter_status.format = '<%= public_storage[:system_status] %>'

