Termtter::Client.add_hook do |statuses, event|
  if !statuses.empty? && event == :update_friends_timeline
    statuses.each do |s|
      system 'growlnotify', 'Termtter', '-m', "#{s.user_screen_name}: #{s.text}", '-n', 'termtter'
    end
  end
end
