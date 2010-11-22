module Termtter::Client
  passwords = {}

  register_command(
    :name => :switch,
    :alias => :switch_user,
    :exec_proc => lambda {|arg|
      user_name = !arg.empty? ? normalize_as_user_name(arg) : nil
      return if user_name == config.user_name

      passwords[config.user_name] = config.password

      file_name_prefix = File.join(Termtter::CONF_DIR, config.token_file_name)
      unless user_name
        choices = [:new, ""]
        choices += Dir.glob(file_name_prefix + "_*").map{|f| f.gsub(file_name_prefix+'_', '')}

        puts "0. New user"
        puts "1. Default"
        choices[2..-1].each_with_index do |c, i| 
          puts "#{i+2}. #{c}"
        end
        ui = create_highline
        choice = choices[ui.ask("Please choice number: ").to_i]
        if choice.nil?
          puts "Invalid number"
          break
        end
        user_name = (choice == :new) ? ui.ask("Enter user name: ") : choice
      end

      config.token_file = file_name_prefix
      config.token_file += "_#{user_name}" if user_name != ""
      config.__clear__(:access_token)
      config.__clear__(:access_token_secret)

      Termtter::API.setup
      execute('reload')
    },
    :help => ["switch USERNAME", "Switch twitter account."]
  )

  register_command(:restore_user) do |arg|
    puts 'Sorry, command "restore_user" was obsoleted, and use command "switch" instead.'
  end
end
