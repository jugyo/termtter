def fibsub(n,i,j)n.times{j=i+i=j};i end
@fibs = {}
def fib(n)
  m = @fibs.select{|k,v|k < n}.max_by{|k,v|k}
  m.nil? ? fibsub(n,0,1) : fibsub(n-m[0],m[1][0],m[1][1])
end
step=100
@fibs[step] = [fib(step), fib(step+1)]
(2..6).each do |i|
  j=i*step
  @fibs[j] = [fib(j), fib(j+1)]
end
Termtter::Client.register_command(:fib) do |arg|
  n = arg.to_i # up to 618
  text = "fib(#{n}) = #{fib n}"
  Termtter::API.twitter.update(text)
  puts "=> " << text
end
