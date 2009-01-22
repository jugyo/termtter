Termtter::Client.register_macro(:cool, "update @%s cool.",
  :help => ['cool {SCREENNAME}', 'update "@{SCREENNAME} cool."'],
  :completion_proc => proc {|cmd, args|
    if args =~ /^([^\s]+)$/
      find_user_candidates $1, "#{cmd} %s"
    end
  }
)
