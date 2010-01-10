# -*- coding: utf-8 -*-
module Termtter::Client
  register_command(
    :name => :random, :aliases => [:rand],
    :exec_proc => lambda {|_|

      unless public_storage[:log]
        puts 'Error: You should load "log" plugin!'
        return
      end

      status = public_storage[:log][rand(public_storage[:log].size)]
      unless status
        puts 'No status.'
        return
      end

      execute("update #{status.text}")

    },
    :help => ['random', 'random post']
  )
end
