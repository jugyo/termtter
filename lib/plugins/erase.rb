Termtter::Client.register_command('erase') do |arg|
  num = /(\d+)/ =~ arg ? $1.to_i : 1
  print "\e[#{num + 1}F\e[0J"
end
