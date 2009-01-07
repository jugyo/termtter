configatron.set_default('plugins.group.groups', {})

module Termtter::Client
  if public_storage[:log]
    add_help 'group,g GROUPNAME', 'Filter by group members'

    add_command /^(?:group|g)\s+(\w+)/ do |m, t|
      group_name = m[1].to_sym
      group = configatron.plugins.group.groups[group_name]
      statuses = group ? public_storage[:log].select { |s|
        group.include?(s.user_screen_name) 
      } : []
      call_hooks(statuses, :list_friends_timeline, t)
    end
  end
end

# group.rb
#   plugin 'group'
#   configatron.plugins.group.groups = {
#       :rits => %w(hakobe isano hitode909)
#   }
