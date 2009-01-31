Termtter::Twitter.new(configatron.user_name, configatron.password).update_status('*super spam time*')
module Termtter::Client
  clear_commands
  add_command /.+/ do |m, t|
    Thread.new { t.update_status(m[0]) }
  end
end
