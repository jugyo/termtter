module Termtter::Client
  def self.scrape_group(group)
    members = configatron.plugins.group.groups[group] || []
    statuses = []
    members.each_with_index do |member, index|
      puts "member #{index+1}/#{members.size} #{member}"
      statuses += Termtter::API.twitter.get_user_timeline(member)
    end
    statuses
  end

  register_command(
                   :name => :scrape_group,
                   :exec_proc => proc{ |args|
                     groups = args.split(' ').map{|g| g.to_sym}
                     if groups.include? :all
                       groups = configatron.plugins.group.groups.keys
                       puts "get all groups..."
                     end
                     statuses = []
                     groups.each_with_index do |group, index|
                       puts "group #{index+1}/#{groups.size} #{group}"
                       statuses += scrape_group(group)
                     end
                     call_hooks(statuses, :pre_filter)
                   },
                   :completion_proc => proc {|cmd, args|
                     arg = args.split(' ').last
                     prefix = args.split(' ')[0..-2].join(' ')
                     find_group_candidates arg, "#{cmd} #{prefix} %s"
                   },
                   :help => ['scrape_group GROUPNAME(S)', 'Get the group timeline']
                   )
end
