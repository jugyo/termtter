#!/usr/bin/env ruby

$KCODE = 'u'

require 'termtter/termtter'

# Hooks
require 'termtter/stdout'
#require 'termtter/notify-send'

# Your account information
user_name = ''
password = ''
update_interval = 60 * 5

client = Termtter.new(user_name, password, update_interval)
client.run
