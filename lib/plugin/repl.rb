# repl.rb doesn't work. below is a sketch
#
# IO.popen('cat -un', 'r+') {|io|
#   io.sync = true
#   io.puts "(print (+ 2 3))"
#   io.puts "(print (+ 2 3))"
#   p io.gets
#   p io.gets
# }
# IO.popen('gosh -b', 'r+') {|io|
#   io.sync = true
#   io.puts "(print (+ 2 3))"
#   io.puts "(print (+ 2 3))"
#   p io.gets
#   p io.gets
# }

module Termtter::Client
  add_command /^\(.*/ do |m, t|
    sexp = m[0].chomp
    value = open('|gosh', 'r+') {|io|
      io.sync = true
      io.puts "(print #{sexp})"
      io.gets
    }
    t.update_status(value)
    puts "=> #{value}"
  end
end

# repl.rb
#   Read Eval Print Loop
#   powered by Gauche the scheme interpreter
# example:
#   > (+ 1 2 3)
#   => 6
# notice:
#   we cannot repl without the first '('
#   > 'aaa
# known bug:
#   it doesn't keep the binding.
