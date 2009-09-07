require 'irb'
Termtter::Client.register_command(:irb) do |*args|
  args.unshift('irb')
  args.delete_if{|i| i == ""}
  system *args
end
