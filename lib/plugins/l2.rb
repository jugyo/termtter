# -*- coding: utf-8 -*-

module Termtter::Client
  register_command(
    :name => :list2,
    :aliases => [:l2],
    :exec_proc => lambda {|arg|
      unless arg.empty?
        targets = arg.split.uniq
        statuses = targets ? targets.map { |target|
          public_storage[:tweet][target]
        }.flatten.uniq.compact.sort_by{ |s| s[:id]} : []
        output(statuses, :search)
      end
    },
    :completion_proc => lambda {|cmd, arg|
      #todo
    },
    :help => ['list2,l2 A B (C..)', "List statuses of A's and B's (and C's..)"]
  )
end

# l2.rb
#   plugin 'l2'
# NOTE: l2.rb needs plugin/log
