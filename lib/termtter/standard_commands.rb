class Termtter::Client

  add_command /^(update|u)\s+(.*)/ do |m, t|
    text = m[2]
    next if text.empty?
    t.update_status(text)
    puts "=> #{text}"
  end

  add_command /^(list|l)\s*$/ do |m, t|
    t.list_friends_timeline()
  end

  add_command /^(list|l)\s+([^\s]+)/ do |m, t|
    t.get_user_timeline(m[2])
  end

  add_command /^(search|s)\s+(.*)/ do |m, t|
    query = m[2]
    unless query.empty?
      t.search(query)
    end
  end

  add_command /^(replies|r)\s*$/ do |m, t|
    t.replies()
  end

  add_command /^show\s+([^\s]+)/ do |m, t|
    t.show($1)
  end

  add_command /^pause\s*$/ do |m, t|
    t.pause
  end

  add_command /^resume\s*$/ do |m, t|
    t.resume
  end

  add_command /^exit\s*$/ do |m, t|
    t.exit
  end

  add_command /^help\s*$/ do |m, t|
    puts <<-EOS
exit            Exit
help            Print this help message
list,l          List the posts in your friends timeline
list USERNAME   List the posts in the the given user's timeline
pause           Pause updating
update,u TEXT   Post a new message
resume          Resume updating
replies,r       List the most recent @replies for the authenticating user
search,s TEXT   Search for Twitter
show ID         Show a single status
EOS
  end

  add_command /^eval\s+(.*)$/ do |m, t|
    result = t.instance_eval m[1] unless m[1].empty?
    puts "=> #{result.inspect}"
  end

end
