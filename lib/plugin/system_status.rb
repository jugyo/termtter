# -*- coding: utf-8 -*-

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
  add_task(:name => :system_status, :interval => configatron.plugins.system_status.interval) do
    status = (@@task_manager.get_task(:update_timeline).exec_at - Time.now).to_i.to_s
    color = public_storage[:system_status_color] ||
                    configatron.plugins.system_status.default_color
    out_put_status(status, color)
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
