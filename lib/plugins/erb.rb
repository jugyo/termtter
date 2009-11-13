# -*- coding: utf-8 -*-
require 'erb'
module Termtter::Client
  register_hook(:erb, :point => :modify_arg_for_update) do |cmd, arg|
    ERB.new(arg).result(binding)
  end
end

# erb.rb
#   enable to <%= %> in the command update
# example:
#   > u erb test <%= 1+1 %>
#   => erb test 2
