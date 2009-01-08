configatron.plugins.history.set_default('filename',
                        '~/.termtter_history')

# undef constructing
Termtter::Client.add_hook do |statuses, event|
  case event
  when :initialize
    puts "will load from #{configatron.plugins.history.filename}"
  when :exit
    puts "will save to #{configatron.plugins.history.filename}"
  end
end

