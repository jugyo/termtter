Termtter::Client.add_hook do |statuses, event|
  if !statuses.empty? && event == :update_friends_timeline
    max = 10
    
    text = statuses[0..(max - 1)].map{|s|
      status_text = s.text.gsub(%r{https?://[-_.!~*\'()a-zA-Z0-9;\/?:\@&=+\$,%#]+},'<a href="\0">\0</a>')
      status_text.gsub!("\n", '')
      "<b>#{s.user_screen_name}:</b> <span font=\"9.0\">#{status_text}</span>"
    }.join("\n")
    
    text += "\n<a href=\"http://twitter.com/\">more…</a>" if statuses.size > max
    
    system 'notify-send', 'Termtter', text, '-t', '60000'
  end
end
