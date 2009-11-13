def fib(n)i=0;j=1;n.times{j=i+i=j};i end
Termtter::Client.register_command(:fib) do |arg|
  n = arg.to_i
  text = "fib(#{n}) = #{fib n}"
  Termtter::API.twitter.update(text)
  puts "=> " << text
end
