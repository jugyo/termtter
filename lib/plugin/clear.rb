# -*- coding: utf-8 -*-

module Termtter::Client
  register_command :name => :clear, :aliases => [:cls],
    :help => ['clear,cls', "Clear termtter's buffer"],
    :exec_proc => lambda {|args|
      system 'clear'
    }
end
