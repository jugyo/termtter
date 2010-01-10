# -*- coding: utf-8 -*-

module Termtter

  module Client

    public_storage[:current] = ''
    public_storage[:orig_prompt] = config.prompt
    config.prompt = "~/ #{public_storage[:orig_prompt]}"

    register_command(
      :name      => :sl, :aliases => [],
      :exec_proc => lambda {|arg| system("sl") },
      :help      => ['sl', 'The train pass in front of your screen']
    )

    register_command(
      :name      => :pwd, :aliases => [],
      :exec_proc => lambda {|arg| public_storage[:current] },
      :help      => ['pwd', 'Show current direcroty']
    )

    register_command(
      :name => :ls, :aliases => [],
      :exec_proc => lambda {|arg|
        if arg.empty? && /\A#/ =~ public_storage[:current]
          execute("search #{public_storage[:current]}")
        elsif /\A#/ =~ arg
          execute("search #{arg}")
        else
          execute("list #{arg.empty? ? public_storage[:current] : arg}")
        end
      },
      :help => ['ls', 'Show list in current directory']
    )

    register_command(
      :name => :cd, :aliases => [],
      :exec_proc => lambda {|arg|
        public_storage[:current] =
          (arg.nil? || /\~/ =~ arg) ? '' : normalize_as_user_name(arg)
        config.prompt = "~/#{public_storage[:current]} #{public_storage[:orig_prompt]}"
      },
      :help => ['cd USER', 'Change current directory']
    )
  end
end

