# -*- coding: utf-8 -*-

module Termtter::Client
  public_storage[:log] = []
  configatron.plugins.log.set_default('max_size', 1/0.0)
  configatron.plugins.log.set_default('print_max_size', 30)

  add_hook do |statuses, event|
    case event
    when :pre_filter
      public_storage[:log] += statuses
      max_size = configatron.plugins.log.max_size
      if public_storage[:log].size > max_size
        public_storage[:log] = public_storage[:log][-max_size..-1]
      end
      public_storage[:log] = public_storage[:log].uniq.sort_by{|a| a.created_at} if statuses.first
    end
  end

  register_command(
   :name => :log,
   :exec_proc => proc{|arg|
     if arg.empty?
       # log
       statuses = public_storage[:log]
       print_max = configatron.plugins.log.print_max_size
       print_max = 0 if statuses.size < print_max
       call_hooks(statuses[-print_max..-1], :search)
     else
       # log (user) (max)
       vars = arg.split(' ')
       print_max = vars.last =~ /^\d+$/ ? vars.pop.to_i : configatron.plugins.log.print_max_size
       id = vars
       statuses = id.first ? public_storage[:log].select{ |s| id.include? s.user_screen_name} : public_storage[:log]
       print_max = 0 if statuses.size < print_max
       call_hooks(statuses[-print_max..-1], :search)
     end
   },
   :completion_proc => proc {|cmd, arg|
     find_user_candidates arg, "#{cmd} %s"
   },
   :help => [ 'log (USER(S)) (MAX)', 'Show local log of the user(s)']
   )

  register_command(
   :name => :search_log, :aliases => [:sl],
   :exec_proc => proc{|arg|
    unless arg.strip.empty?
      pat = Regexp.new arg
      statuses = public_storage[:log].select { |s| s.text =~ pat }
      call_hooks(statuses, :search)
     end
   },
   :help => [ 'search_log WORD', 'Search log for WORD' ]
   )

  add_command %r'^/(.+)' do |m, t|
    warn '/WORD command will be removed. Use search_log command instead.'
    pat = Regexp.new(m[1])
    statuses = public_storage[:log].select { |s| s.text =~ pat }
    call_hooks(statuses, :search, t)
  end
end
