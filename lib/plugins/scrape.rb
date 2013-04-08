# -*- coding: utf-8 -*-

module Termtter::Client

  def self.scrape_members(members)
    statuses = []
    members.each_with_index do |member, index|
      puts "member #{index+1}/#{members.size} #{member}"
      statuses += Termtter::API.twitter.user_timeline(:screen_name => member, :include_entities => 1)
    end
    statuses
  end    
  
  def self.scrape_group(group)
    members = config.plugins.group.groups[group] || []
    scrape_members(members)
  end

  register_command(
                   :name => :scrape_group,
                   :exec_proc => lambda{ |args|
                     groups = args.split(' ').map{|g| g.to_sym}
                     if groups.include? :all
                       groups = config.plugins.group.groups.keys
                       puts "get all groups..."
                     end
                     members = []
                     groups.each do |group|
                       members += config.plugins.group.groups[group]
                     end
                     statuses = scrape_members(members.uniq.compact.sort)
                     output(statuses_to_hash(statuses), :pre_filter)
                   },
                   :completion_proc => lambda {|cmd, args|
                     arg = args.split(' ').last
                     prefix = args.split(' ')[0..-2].join(' ')
                     find_group_candidates arg, "#{cmd} #{prefix} %s"
                   },
                   :help => ['scrape_group GROUPNAME(S)', 'Get the group timeline']
                   )
end
