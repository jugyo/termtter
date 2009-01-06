require 'erb'

module Termtter::Client
  add_command /^(update|u)\s+(.*)/ do |m, t|
    text = ERB.new(m[2]).result(binding).gsub(/\n/, ' ')
    unless text.empty?
      t.update_status(text)
      puts "=> #{text}"
    end
  end
end

# erb.rb
#   enable to <%= %> in the command update
# example:
#   > u erb test <%= 1+1 %>
#   => erb test 2
