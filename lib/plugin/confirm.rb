module Termtter::Client

  add_command /^confirm\s+(.*)/ do |m, t|
    text = m[1]
    unless text.empty?
      pause
      print "update? #{text} [Y/n] "
      buf = Readline.readline("", false)
      t.update_status(text) if /^y?$/i =~ buf
      resume
    end
  end

  add_completion do |input|
    case input
    when /^(confirm)\s+(.*)@([^\s]*)$/
      find_user_candidates $3, "#{$1} #{$2}@%s"
    else
      ['confirm'].grep(/^#{Regexp.quote input}/)
    end
  end

end

