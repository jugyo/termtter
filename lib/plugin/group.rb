configatron.set_default('plugins.group.groups', {})

module Termtter::Client
  if public_storage[:log]
    add_help 'group,g GROUPNAME', 'Filter by group members'

    add_command /^(?:group|g)\s+(.+)/ do |m, t|
      group_name = m[1].to_sym
      group = configatron.plugins.group.groups[group_name]
      statuses = group ? public_storage[:log].select { |s|
        group.include?(s.user_screen_name) 
      } : []
      call_hooks(statuses, :list_friends_timeline, t)
    end

    def self.find_group_candidates(a, b)
      configatron.plugins.group.groups.keys.map {|k| k.to_s}.
        grep(/^#{Regexp.quote a}/).
        map {|u| b % u }
    end

    add_completion do |input|
      case input
      when /^(group|g)?\s+(.+)/
        find_group_candidates($2, "#{$1} %s")
      when /^(group|g)\s+$/
        configatron.plugins.group.groups.keys
      else
        %w(group).grep(/^#{Regexp.quote input}/)
      end
    end
  end
end

# group.rb
#   plugin 'group'
#   configatron.plugins.group.groups = {
#       :rits => %w(hakobe isano hitode909)
#   }
# NOTE: group.rb needs plugin/log
