Termtter::Client.register_command(:irb) do |args|
  require 'irb'
  IRB.start
end
