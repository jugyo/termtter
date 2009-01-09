module Termtter::Client
  public_storage[:log] = []
  configatron.plugins.log.set_default('max_size', 1/0.0)

  add_help '/WORD', 'Search log for WORD'

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
    call_hooks(statuses, :list_friends_timeline, t)
  end

  add_help 'log', 'Show local log'
  add_help 'log USER', 'Show local log of the user'

  add_command /^(log)\s*$/ do |m, t|
    call_hooks(public_storage[:log], :list_friends_timeline, t)
  end

  add_command /^(log)\s+([^\s]+)/ do |m, t|
    statuses = public_storage[:log].select{ |s| s.user_name == m[2]}
    call_hooks(statuses, :list_friends_timeline, t)
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
