module Termtter::Client
  add_help 'shell,sh', 'Start your shell'
  add_macro /^(?:shell|sh)/, "eval system ENV['SHELL'] || ENV['COMSPEC']"
end
