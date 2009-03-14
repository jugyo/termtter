# -*- coding: utf-8 -*-

module Termtter
  class Status
    def is_member?(group = nil)
      if group
        configatron.plugins.group.groups[group].include? self.user.screen_name
      else
        configatron.plugins.group.groups.values.flatten.include? self.user.screen_name
      end
    end
  end
end

module Termtter::Client
  configatron.plugins.group.
    set_default(:groups, {})

  def self.find_group_candidates(a, b)
    configatron.plugins.group.groups.keys.map {|k| k.to_s}.
      grep(/^#{Regexp.quote a}/).
      map {|u| b % u }
  end

  register_command(
   :name => :group,
   :aliases => [:g],
   :exec_proc => lambda {|arg|
     unless arg.empty?
       group_name = arg.to_sym
       if group_name == :all
         group = configatron.plugins.group.groups.values.flatten.uniq
       else
         group = configatron.plugins.group.groups[group_name]
       end
       statuses = group ? public_storage[:log].select { |s|
         group.include?(s.user.screen_name) 
       } : []
       call_hooks(statuses, :search)
     else
       configatron.plugins.group.groups.each_pair do |key, value|
         puts "#{key}: #{value.join(',')}"
       end
     end
   },
   :completion_proc => lambda {|cmd, arg|
     find_group_candidates arg, "#{cmd} %s"
                   },
   :help => ['group,g GROUPNAME', 'Filter by group members']
   )
  
end

# group.rb
#   plugin 'group'
#   configatron.plugins.group.groups = {
#     :rits => %w(hakobe isano hitode909)
#   }
# NOTE: group.rb needs plugin/log

