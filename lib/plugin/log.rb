module Termtter::Client
  public_storage[:log] = []
  configatron.plugins.log.set_default('max_size', 1/0.0)
  configatron.plugins.log.set_default('print_max_size', 30)

  add_help '/WORD', 'Search log for WORD'
  add_help 'log', 'Show local log'
  add_help 'log (USER(S)) (MAX)', 'Show local log of the user(s)'

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

  add_command %r'^/(.+)' do |m, t|
    pat = Regexp.new(m[1])
    statuses = public_storage[:log].select { |s| s.text =~ pat }
    call_hooks(statuses, :search, t)
  end

  # log
  add_command /^(log)\s*$/ do |m, t|
    statuses = public_storage[:log]
    print_max = configatron.plugins.log.print_max_size
    print_max = 0 if statuses.size < print_max
    call_hooks(statuses[-print_max..-1], :search, t)
  end

  # log (user) (max)
  add_command /^(log)\s+(.+)\s*/ do |m, t|
    vars = m[2].split(' ')
    print_max = vars.last =~ /^\d+$/ ? vars.pop.to_i : configatron.plugins.log.print_max_size
    id = vars
    statuses = id.first ? public_storage[:log].select{ |s| id.include? s.user_screen_name} : public_storage[:log]
    print_max = 0 if statuses.size < print_max
    call_hooks(statuses[-print_max..-1].compact, :search, t)
  end

  add_completion do |input|
    case input
    when /^(log)\s+(.*)/
      find_user_candidates $2, "#{$1} %s"
    else
      %w[ log ].grep(/^#{Regexp.quote input}/)
    end
  end

end
