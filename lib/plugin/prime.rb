def prime(n)
  table = []
  (2 .. n).each do |i|
    table << i
  end

  prime = []
  loop do
    prime << table[0]
    table = table.delete_if {|x| x % prime.max == 0 }
    break if table.max < (prime.max ** 2)
  end

  r = (table+prime).sort {|a, b| a<=>b }
  r.join(' ')
end

module Termtter::Client
  add_command /^prime\s(\d+)/ do|m,t|t.update_status x="prime(#{n=m[1].to_i}) = #{prime n}"
    puts "=> #{x}" end
end
