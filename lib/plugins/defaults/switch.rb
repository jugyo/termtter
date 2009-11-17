module Termtter::Client
  passwords = {}

  register_command(
    :name => :switch,
    :alias => :switch_user,
    :exec_proc => lambda {|arg|
      user_name = !arg.empty? ? normalize_as_user_name(arg) : nil
      return if user_name == config.user_name

      passwords[config.user_name] = config.password

      if user_name
        config.user_name = normalize_as_user_name(arg)
        if passwords.key?(config.user_name)
          config.password = passwords[config.user_name]
        else
          config.__clear__(:password)
        end
      else
        config.__clear__(:user_name)
        config.__clear__(:password)
      end

      Termtter::API.setup
      call_commands('reload')
    },
    :help => ["switch USERNAME", "Switch twitter account."]
  )

  register_command(:restore_user) do |arg|
    puts 'Sorry, command "restore_user" was obsoleted, and use command "switch" instead.'
  end
end
