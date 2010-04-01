module Termtter::Client
  register_command(
    :name => :capital_update,
    :author => 'ujihisa',
    :alias => :cu,
    :help =>[
      'capital_update, cu',
      'Posts a tweet all in captalized text.'],
    :exec_proc => lambda {|arg|
      execute('update ' + arg.upcase)
    })
end
