require 'erb'

configatron.set_default(
  :timeline_format,
  '<%= color(time, 90) %> <%= color(status, status_color) %> <%= color(id, 90) %>')

if RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|bccwin/
  require 'kconv'
  def color(str, num)
    str.to_s.tosjis
  end
  def puts(str)
    STDOUT.puts(str.tosjis)
  end
else
  def color(str, num)
    "\e[#{num}m#{str}\e[0m"
  end
end

Termtter::Client.add_hook do |statuses, event|
  colors = %w(0 31 32 33 34 35 36 91 92 93 94 95 96)

  case event
  when :update_friends_timeline, :list_friends_timeline, :list_user_timeline, :show, :replies
    unless statuses.empty?
      statuses.reverse! if event == :update_friends_timeline
      statuses.each do |s|
        text = s.text
        status_color = colors[s.user_screen_name.hash % colors.size]
        status = "#{s.user_screen_name}: #{text}"
        if s.in_reply_to_status_id
          status += " (reply to #{s.in_reply_to_status_id})"
        end

        time_format = case event
          when :update_friends_timeline, :list_friends_timeline
            '%H:%M:%S'
          else
            '%m-%d %H:%M'
          end
        time = "(#{s.created_at.strftime(time_format)})"

        id = s.id

        puts ERB.new(configatron.timeline_format).result(binding)
      end
    end
  when :search
    statuses.each do |s|
      text = s.text
      status_color = colors[s.user_screen_name.hash % colors.size]

      status = "#{s.user_screen_name}: #{text}"
      time = "(#{s.created_at.strftime('%m-%d %H:%M')})"
      id = s.id
      puts ERB.new(configatron.timeline_format).result(binding)
    end
  end
end
