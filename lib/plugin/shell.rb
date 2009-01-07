module Termtter::Client
  add_command /^shell/ do |_, _|
    system ENV['SHELL'] || ENV['COMSPEC']
  end
end
