module Termtter::Client
  begin
    require 'g'
    register_command(
      :name      => :g,
      :help      => ['g obj', "Do you know 'g'? It's like 'p'."],
      :exec_proc => lambda {|arg|
        # we get arg as String, so without eval() it is not very useful
        # but we shouldn't blindly eval user-supplied string like this, either
        g eval(arg)
      }
    )
  rescue e
    handle_error(e)
  end
end