# -*- coding: utf-8 -*-

module Termtter::Client
  register_command(
    :name => :follow, :aliases => [],
    :exec_proc => lambda {|args|
      args.split(' ').each do |arg|
        if arg =~ /^(\w+)/
          res = Termtter::API::twitter.follow($1.strip)
        end
      end
    },
    :completion_proc => lambda {|cmd, args|
      find_user_candidates args, "#{cmd} %s"
    },
	:help => ['follow USER', 'Follow user']
  )

  register_command(
    :name => :leave, :aliases => [],
    :exec_proc => lambda {|args|
      args.split(' ').each do |arg|
        if arg =~ /^(\w+)/
          res = Termtter::API::twitter.leave($1.strip)
        end
      end
    },
    :completion_proc => lambda {|cmd, args|
      find_user_candidates args, "#{cmd} %s"
    },
	:help => ['leave USER', 'Leave user']
  )
end
