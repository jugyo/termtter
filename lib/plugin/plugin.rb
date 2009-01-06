module Termtter::Client
  add_command /^plugin\s+(.*)/ do |m, t|
    plugin m[1]
  end
end

# plugin.rb
#   a dynamic plugin loader
# example
#   > u <%= not erbed %>
#   => <%= not erbed %>
#   > plugin erb
#   > u <%= 1 + 2 %>
#   => 3
