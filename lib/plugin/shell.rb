module Termtter::Client
  register_command :name => :shell, :aliases => [:sh],
    :help => ['shell,sh', 'Start your shell'],
    :exec_proc => proc {|args|
      begin
        pause
        system ENV['SHELL'] || ENV['COMSPEC']
      ensure
        resume
      end
    }
end
