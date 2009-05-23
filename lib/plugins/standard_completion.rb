# -*- coding: utf-8 -*-

module Termtter::Client

  public_storage[:users] ||= Set.new
  public_storage[:status_ids] ||= Set.new

  register_hook(
    :name => :for_completion,
    :points => [:pre_filter],
    :exec_proc => lambda {|statuses, event|
      statuses.each do |s|
        public_storage[:users].add(s.user.screen_name)
        public_storage[:users] += s.text.scan(/@([a-zA-Z_0-9]*)/).flatten
        public_storage[:status_ids].add(s.id)
        public_storage[:status_ids].add(s.in_reply_to_status_id) if s.in_reply_to_status_id
      end
    }
  )

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
