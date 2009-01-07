module Termtter::Client
  add_help 'shell,sh', 'Start your shell'
  add_command /^(?:shell|sh)/ do |_, _|
    system ENV['SHELL'] || ENV['COMSPEC']
  end
end
