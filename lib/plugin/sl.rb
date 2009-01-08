module Termtter::Client
  add_command /^sl$/ do |_, _|
    system 'sl'
  end
end
