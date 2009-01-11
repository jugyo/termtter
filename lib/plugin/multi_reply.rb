module Termtter::Client
  add_help 'multi_reply, mp TEXT', 'reply to multi user'
  add_command /^(multi_reply|mr)\s+(.*)/ do |m, t|
    text = ERB.new(m[2]).result(binding).gsub(/\n/, ' ')
    unless text.empty?
      #targets, _, msg = text.match /(@(.+))*\s+(.+)/
      #targets.split(/\s+/).
      #  map {|u| "#{u} #{msg}" }.
      #  each do |post|
      #    t.update_status(post)
      #    puts "=> #{post}"
      #  end
      /(@(.+))*\s+(.+)/ =~ text
      if $1
        msg = $3
        text = $1.split(/\s+/).map {|u| "#{u} #{msg}" }
      end
      Array(text).each do |post|
        t.update_status(post)
        puts "=> #{post}"
      end
      #
    end
  end

  add_completion do |input|
    case input
    when /^(multi_reply|mr)\s+(.*)@([^\s]*)$/
      find_user_candidates $3, "#{$1} #{$2}@%s"
    else
      %w[ mreply mp ].grep(/^#{Regexp.quote input}/)
    end
  end
end
