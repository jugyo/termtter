def fib(n)i=0;j=1;n.times{j=i+i=j};i end
module Termtter::Client
add_command /^fib\s+(\d+)/ do|m,t|t.update_status x="fib(#{n=m[1].to_i}) = #{fib n}"
puts"=> #{x}"end end
