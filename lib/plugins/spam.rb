# -*- coding: utf-8 -*-

Termtter::Twitter.new(config.user_name, config.password).update_status('*super spam time*')
module Termtter::Client
  clear_commands
  add_command /.+/ do |m, t|
    Thread.new { t.update_status(m[0]) }
  end
end
