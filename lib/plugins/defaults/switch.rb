module Termtter::Client
  register_command(
    :name => :switch,
    :alias => :switch_user,
    :exec_proc => lambda {|arg|
      if arg.empty?
        config.__clear__(:user_name)
      else
        config.user_name = normalize_as_user_name(arg)
      end
      config.__clear__(:password)
      Termtter::API.setup
    },
    :help => ["switch USERNAME", "Switch twitter account."]
  )

  register_command(:restore_user) do |arg|
    puts 'Sorry, command "restore_user" was obsoleted, and use command "switch" instead.'
  end
end
