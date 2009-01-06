module Termtter::Client

  # standard commands

  add_command /^(update|u)\s+(.*)/ do |m, t|
    text = m[2]
    unless text.empty?
      t.update_status(text)
      puts "=> #{text}"
    end
  end

  add_command /^(list|l)\s*$/ do |m, t|
    statuses = t.get_friends_timeline()
    call_hooks(statuses, :list_friends_timeline, t)
  end

  add_command /^(list|l)\s+([^\s]+)/ do |m, t|
    statuses = t.get_user_timeline(m[2])
    call_hooks(statuses, :list_user_timeline, t)
  end

  add_command /^(search|s)\s+(.+)/ do |m, t|
    call_hooks(t.search(m[2]), :search, t)
  end

  add_command /^(replies|r)\s*$/ do |m, t|
    call_hooks(t.replies(), :replies, t)
  end

  add_command /^show\s+([^\s]+)/ do |m, t|
    call_hooks(t.show(m[1]), :show, t)
  end

  add_command /^pause\s*$/ do |m, t|
    pause
  end

  add_command /^resume\s*$/ do |m, t|
    resume
  end

  add_command /^exit\s*$/ do |m, t|
    exit
  end

  add_command /^help\s*$/ do |m, t|
    puts <<-EOS
exit              Exit
help              Print this help message
list,l            List the posts in your friends timeline
list,l USERNAME   List the posts in the the given user's timeline
pause             Pause updating
update,u TEXT     Post a new message
resume            Resume updating
replies,r         List the most recent @replies for the authenticating user
search,s TEXT     Search for Twitter
show ID           Show a single status
    EOS
  end

  add_command /^eval\s+(.*)$/ do |m, t|
    begin
      result = eval(m[1]) unless m[1].empty?
      puts "=> #{result.inspect}"
    rescue SyntaxError => e
      puts e
    end
  end

  # completion for standard commands

  require 'set'
  public_storage[:users] ||= Set.new
  public_storage[:status_ids] ||= Set.new

  add_hook do |statuses, event, t|
    statuses.each do |s|
      public_storage[:users].add(s.user_screen_name)
      public_storage[:users] += s.text.scan(/@([a-zA-Z_0-9]*)/).flatten
      public_storage[:status_ids].add(s.id.to_s)
      public_storage[:status_ids].add(s.in_reply_to_status_id.to_s) if s.in_reply_to_status_id
    end
  end

  def self.find_status_id_candidates(a, b)
    if a.empty?
      public_storage[:status_ids].to_a
    else
      public_storage[:status_ids].grep(/#{Regexp.quote a}/)
    end.
    map {|u| b % u }
  end

  def self.find_user_candidates(a, b)
    if a.empty?
      public_storage[:users].to_a
    else
      public_storage[:users].grep(/^#{Regexp.quote a}/i)
    end.
    map {|u| b % u }
  end

  add_completion do |input|
    standard_commands = %w[exit help list pause update resume replies search show]
    case input
    when /^(list|l)?\s+(.*)/
      find_user_candidates $2, "#{$1} %s"
    when /^(update|u)\s+(.*)@([^\s]*)$/
      find_user_candidates $3, "#{$1} #{$2}@%s"
    when /^show\s+(.*)/
      find_status_id_candidates $1, "show %s"
    else
      standard_commands.grep(/^#{Regexp.quote input}/)
    end
  end

end
