def fib(n)i=0;j=1;n.times{j=i+i=j};i end
Termtter::Client.register_command(:name => :fib,
                                  :aliases => [:f, :ho],
                                  :exec => lambda do |arg|
  case arg
  when "ukumori"
    puts 'Does it mean "Sora Harakami (@sora_h)"?'
  when "ootsuite", "otsuite"
    puts "NDA :D"
  else
    n = arg.to_i
    text = "fib(#{n}) = #{fib n}"
    Termtter::API.twitter.update(text)
    puts "=> " << text
  end
end)
