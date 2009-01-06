module Termtter::Client
  add_help 'plugin FILE', 'Load a plugin'

  add_command /^plugin\s+(.*)/ do |m, t|
    begin
      result = plugin m[1]
    rescue LoadError
    ensure
      puts "=> #{result.inspect}"
    end
  end
end

# plugin.rb
#   a dynamic plugin loader
# example
#   > u <%= not erbed %>
#   => <%= not erbed %>
#   > plugin erb
#   => true
#   > u <%= 1 + 2 %>
#   => 3
