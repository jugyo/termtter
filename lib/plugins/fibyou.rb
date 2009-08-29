# It depends on defaults/fib.rb

module Termtter::Client
  register_command(:fibyou) do |arg|
    /(\w+)\s(\d+)/ =~ arg
    name = normalize_as_user_name($1)
    n = $2.to_i
    text = "@#{name} fib(#{n}) = #{fib n}"
    Termtter::API.twitter.update(text)
    puts "=> " << text
  end
end
