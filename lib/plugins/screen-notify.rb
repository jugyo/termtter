
if config.screen_notify.format.nil? or config.screen_notify.format.empty?
  config.screen_notify.format = "[termtter] @%s"
end

Termtter::Client.add_hook do |statuses, event|
  if !statuses.empty? && event == :update_friends_timeline
    statuses.reverse.each do |s|
      msg = config.screen_notify.format % [s.user.screen_name, s.text]
      system 'screen', '-X', 'eval', "bell_msg '#{msg}'", 'bell'
    end
  end
end
