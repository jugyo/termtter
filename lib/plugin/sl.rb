module Termtter::Client
  public_storage[:current] = ''

  register_command(
    :name => :sl, :aliases => [],
    :exec_proc => proc {|arg|
      eval system("sl")
    },
    :help => ['sl', 'The train pass in front of your screen']
  )

  register_command(
    :name => :pwd, :aliases => [],
    :exec_proc => proc {|arg|
      public_storage[:current]
    },
    :help => ['pwd', 'Show current direcroty']
  )

  register_command(
    :name => :ls, :aliases => [],
    :exec_proc => proc {|arg|
      if arg.empty?
        call_commands "list #{public_storage[:current]}", t
      else
        call_commands "list #{arg}", t
      end
    },
    :completion_proc => proc {|cmd, args|
      find_user_candidates args, "#{cmd} %s"
    },
    :help => ['ls', 'Show list in current directory']
  )

  register_command(
    :name => :cd, :aliases => [],
    :exec_proc => proc {|arg|
	  if arg.empty?
        public_storage[:current] = ''
      else
        arg = '' if /\~/ =~ arg
        public_storage[:current] = arg
      end
      puts "=> #{arg}"
	},
    :completion_proc => proc {|cmd, args|
      find_user_candidates args, "#{cmd} %s"
    },
    :help => ['cd USER', 'Change current directory']
  )
end
