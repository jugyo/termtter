module Termtter::Client
  register_command(:eval, :help => ['eval EXPR', 'evaluate expression']) do |arg|
    result = eval(arg) unless arg.empty?
    puts "=> #{result.inspect}"
  end
end
