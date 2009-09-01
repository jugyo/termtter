# -*- coding: utf-8 -*-

module Termtter::Client
  config.plugins.group.
    set_default(:groups, {})
  config.plugins.group.
    set_default(:default_filter, nil)

  def self.find_group_candidates(a, b)
    config.plugins.group.groups.keys.map {|k| k.to_s}.
      grep(/^#{Regexp.quote a}/).
      map {|u| b % u }
  end

  def self.get_group_of(screen_name)
    config.plugins.group.groups.select{ |k, v| v.include? screen_name}.map{|a| a.first}
  end    

  register_command(
   :name => :group,
   :aliases => [:g],
   :exec_proc => lambda {|arg|
     unless arg.empty?
       group_name = arg.to_sym
       groups = config.plugins.group.groups
       if group_name == :all
         targets = groups.values.flatten.uniq
       elsif groups.keys.include? group_name
         targets = groups[group_name]
       else
         ignore_cased = groups.keys.map(&:to_s).grep(/^#{group_name}$/i).map(&:to_sym)
         if ignore_cased.length == 1
           targets = groups[ignore_cased.first]
         elsif ignore_cased.length > 1 
           puts "which? #{ignore_cased.inspect.gsub(':','')}"
         end
       end
       if targets
         statuses = targets ? targets.map { |target|
           public_storage[:tweet][target]
         }.flatten.uniq.compact.sort_by{ |s| s[:id]} : []
         output(statuses, :search)
       end
     else
       config.plugins.group.groups.each_pair do |key, value|
         puts "#{key}: #{value.join(',')}"
       end
     end
   },
   :completion_proc => lambda {|cmd, arg|
     find_group_candidates arg, "#{cmd} %s"
                   },
   :help => ['group,g GROUPNAME', 'Filter by group members']
   )

  def self.is_member?(status, group = nil)
    if group
      config.plugins.group.groups[group].include? status.user.screen_name
    else
      config.plugins.group.groups.values.flatten.include? status.user.screen_name
    end
  end

  register_hook(
    :name => :group_filter,
    :point => :filter_for_output,
    :exec_proc => lambda do |statuses, event|
      return statuses unless event == :update_friends_timeline
      return statuses unless config.plugins.group.default_filter
      filter_group = config.plugins.group.default_filter
      r = []
      statuses.each do |s|
        unless self.is_member?(s, filter_group)
          r << s
        end
      end
      r
    end
  )
end

# group.rb
#   t.plug 'group'
#   config.plugins.group.groups = {
#     :rits => %w(hakobe isano hitode909)
#   }
#   config.plugins.group.default_filter = :rits
# NOTE: group.rb needs plugin/log

