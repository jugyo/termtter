# -*- coding: utf-8 -*-

module Termtter

  module Client

    public_storage[:current] = ''
    public_storage[:orig_prompt] = configatron.prompt
    configatron.prompt = "~/ #{public_storage[:orig_prompt]}"

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
        call_commands("list #{arg.empty? ? public_storage[:current] : arg}", API.twitter)
      },
      :completion_proc => lambda {|cmd, args|
        find_user_candidates args, "#{cmd} %s"
      },
      :help => ['ls', 'Show list in current directory']
    )

    register_command(
      :name => :cd, :aliases => [],
      :exec_proc => lambda {|arg|
        public_storage[:current] =
          (arg.nil? || /\~/ =~ arg) ? '' : arg
        configatron.prompt = "~/#{public_storage[:current]} #{public_storage[:orig_prompt]}"
      },
      :completion_proc => lambda {|cmd, args|
        find_user_candidates args, "#{cmd} %s"
      },
      :help => ['cd USER', 'Change current directory']
    )
  end
end

