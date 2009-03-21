# -*- coding: utf-8 -*-

module Termtter::Client
  public_storage[:log] = []
  public_storage[:tweet] = { }
  config.plugins.log.set_default('max_size', 1/0.0)
  config.plugins.log.set_default('print_max_size', 30)

  register_hook(
    :name => :log,
    :points => [:pre_filter],
    :exec_proc => lambda {|statuses, event|
      # log(sequential storage)
      public_storage[:log] += statuses
      max_size = config.plugins.log.max_size
      if public_storage[:log].size > max_size
        public_storage[:log] = public_storage[:log][-max_size..-1]
      end
      public_storage[:log] = public_storage[:log].uniq.sort_by{|s| s.created_at} if statuses.first

      # tweet(storage for each user)
      statuses.each do |s|
        public_storage[:tweet][s.user.screen_name] = [] unless public_storage[:tweet][s.user.screen_name]
        public_storage[:tweet][s.user.screen_name] << s
        if public_storage[:tweet].size > max_size
          public_storage[:tweet] = public_storage[:tweet][-max_size..-1]
        end
      end
    }
  )

  register_command(
   :name => :log,
   :exec_proc => lambda{|arg|
     if arg.empty?
       # log
       statuses = public_storage[:log]
       print_max = config.plugins.log.print_max_size
       print_max = 0 if statuses.size < print_max
       output(statuses[-print_max..-1], :search)
     else
       # log (user) (max)
       vars = arg.split(' ')
       print_max = vars.last =~ /^\d+$/ ? vars.pop.to_i : config.plugins.log.print_max_size
       id = vars
       statuses = id.first ? public_storage[:log].select{ |s| id.include? s.user.screen_name} : public_storage[:log]
       print_max = 0 if statuses.size < print_max
       output(statuses[-print_max..-1], :search)
     end
   },
   :completion_proc => lambda {|cmd, arg|
     find_user_candidates arg, "#{cmd} %s"
   },
   :help => [ 'log (USER(S)) (MAX)', 'Show local log of the user(s)']
   )

  register_command(
   :name => :search_log, :aliases => [:sl],
   :exec_proc => lambda{|arg|
    unless arg.strip.empty?
      pat = Regexp.new arg
      statuses = public_storage[:log].select { |s| s.text =~ pat }
      output(statuses, :search)
     end
   },
   :help => [ 'search_log WORD', 'Search log for WORD' ]
   )

end
