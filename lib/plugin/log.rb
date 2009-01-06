module Termtter::Client
  public_storage[:log] = []

  add_help '/word', 'Search log'

  add_hook do |statuses,event|
    case event
    when :update_friends_timeline
      public_storage[:log] += statuses
    end
  end

  add_command %r'^/(.+)' do |m,t|
    pat = Regexp.new(m[1])
    statuses = public_storage[:log].select { |s| s.text =~ pat }
    call_hooks(statuses, :list_friends_timeline, t)
  end
end
