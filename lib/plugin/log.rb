module Termtter::Client
  public_storage[:log] = []
  configatron.plugins.log.set_default('max_size', 1/0.0)

  add_help '/WORD', 'Search log for WORD'

  add_hook do |statuses, event|
    case event
    when :update_friends_timeline
      public_storage[:log] += statuses
      max_size = configatron.plugins.log.max_size
      if public_storage[:log].size > max_size
        public_storage[:log] = public_storage[:log][-max_size..-1]
      end
      public_storage[:log].uniq!
    end
  end

  add_command %r'^/(.+)' do |m, t|
    pat = Regexp.new(m[1])
    statuses = public_storage[:log].select { |s| s.text =~ pat }
    call_hooks(statuses, :list_friends_timeline, t)
  end
end
