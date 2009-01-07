module Termtter::Client
  add_command /^shell/ do |_, _|
    system ENV['SHELL']
  end
end
