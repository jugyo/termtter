require 'g'
Termtter::Client.register_command(
  :g,
  :help => ['g OBJECT', "Do you know 'g'? It's like 'p'."]
) do |arg|
  # we get arg as String, so without eval() it is not very useful
  # but we shouldn't blindly eval user-supplied string like this, either
  g eval(arg)
end
