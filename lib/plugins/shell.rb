# -*- coding: utf-8 -*-

module Termtter::Client
  register_command :name => :shell, :aliases => [:sh],
    :help => ['shell,sh', 'Start your shell'],
    :exec_proc => lambda {|args|
      system ENV['SHELL'] || ENV['COMSPEC']
    }
end
