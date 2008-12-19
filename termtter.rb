#!/usr/bin/env ruby

$KCODE = 'u'

require 'termtter/termtter'

# Hooks
require 'termtter/stdout'
#require 'termtter/notify-send'

# Your account information
user_name = ''
password = ''

update_interval = 60

client = Termtter.new(user_name, password)

Thread.new do
  while true
    client.fetch_timeline
    sleep update_interval
  end
end

stty_save = `stty -g`.chomp
trap("INT") { system "stty", stty_save; exit }

while buf = Readline.readline("", true)
  unless buf.empty?
    client.update_status(buf)
    puts "post> #{buf}"
  end
end
