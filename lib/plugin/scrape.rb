module Termtter::Client
  def self.scrape_group(group, t)
    statuses = []
    members = configatron.plugins.group.groups[group] || []
    members.each_with_index{ |member, index|
      statuses += t.get_user_timeline(member)
    }
    statuses
  end

  def self.scrape_groups(t)
    statuses = []
    groups = configatron.plugins.group.groups
    groups.each_with_index{ |group, index|
      statuses += scrape_group(t)
    }
    statuses
  end

  add_help 'scrape_group GROUPNAME', 'Get the group timeline'
  add_help 'scrape_groups', 'Get all groups timeline'
  
  add_command /^(?:scrape_group)\s+(.+)/ do |m, t|
    group_name = m[1].to_sym
    statuses = scrape_group(group_name, t)
    call_hooks(statuses, :pre_filter, t)
    puts "done"
  end

  add_command /^(?:scrape_groups)\s*$/ do |m, t|
    statuses = scrape_groups(t)
    call_hooks(statuses, :pre_filter, t)
    puts "done"
  end

  add_completion do |input|
    case input
    when /^(scrape_group)?\s+(.+)/
      find_group_candidates($2, "#{$1} %s") if defined? find_group_candidates
    when /^(scrape_group)\s+$/
      configatron.plugins.group.groups.keys
    else
      %w(scrape_group scrape_groups).grep(/^#{Regexp.quote input}/)
    end
  end

end
