# -*- coding: utf-8 -*-

module Termtter::Client
  register_hook(:user_name_completion, :point => :completion) do |input|
    if /(.*)@([^\s]*)$/ =~ input
      command_str = $1
      part_of_user_name = $2

      users = 
        if part_of_user_name.nil? || part_of_user_name.empty?
          public_storage[:users].to_a
        else
          public_storage[:users].grep(/^#{Regexp.quote(part_of_user_name)}/i)
        end

      users.map {|u| "#{command_str}@%s" % u }
    end
  end
end
