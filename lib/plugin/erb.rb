# -*- coding: utf-8 -*-

require 'erb'

Termtter::Client.register_hook(
  :name => :erb,
  :points => [:pre_exec_update],
  :exec_proc => proc {|cmd, arg|
    ERB.new(arg).result(binding)
  }
)

# erb.rb
#   enable to <%= %> in the command update
# example:
#   > u erb test <%= 1+1 %>
#   => erb test 2
