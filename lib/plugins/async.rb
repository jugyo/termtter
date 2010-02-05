module Termtter::Client
  register_command(
    :async,
    :alias => :a,
    :help => ['async COMMAND', 'asynchronously execute the command'],
    :completion => lambda {|cmd, arg|
      commands.
        map {|name, command| command.complement(arg) }.
        flatten.
        compact.
        map {|i| "#{cmd} #{i}" }
    },
    :exec => lambda {|arg|
      @task_manager.invoke_later do
        begin
          execute(arg)
        rescue Exception => e
          handle_error(e)
        end
        Readline.refresh_line
      end
    }
  )
end
