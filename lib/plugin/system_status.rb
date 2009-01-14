require 'erb'

configatron.plugins.system_status.set_default(:default_status_proc, proc { Time.now.strftime("%x %X") })
configatron.plugins.system_status.set_default(:interval, 1)
configatron.plugins.system_status.set_default(:default_color, :on_blue)
configatron.plugins.system_status.set_default(:format, '<%= status %>')

def out_put_status(status, color)
  formatted_status = ERB.new(configatron.plugins.system_status.format).result(binding)
  colored_status = color(formatted_status, color)
  print "\e[s\e[1000G\e[#{status.size - 1}D#{colored_status}\e[u"
  $stdout.flush
end

module Termtter::Client
  Thread.new do
    loop do
      begin
        status = public_storage[:system_status] ||
                    configatron.plugins.system_status.default_status_proc.call
        color = public_storage[:system_status_color] ||
                        configatron.plugins.system_status.default_color
      rescue => e
        status = e.message
        color = :on_red
      end
      out_put_status(status, color)
      sleep configatron.plugins.system_status.interval
    end
  end
end

# system_status.rb
#   show system status on left side.
#   output public_storage[:system_status] or Time.now.strftime("%x %X") if nil
# example config
#   configatron.plugins.system_status.default_status_proc = proc { Time.now.strftime("%x %X") }
#   configatron.plugins.system_status.interval = 1
#   configatron.plugins.system_status.default_color = :on_blue
#   configatron.plugins.system_status.format = '<%= status %>'

