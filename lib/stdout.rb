require 'parsedate'

def color(str, num)
  "\e[#{num}m#{str}\e[0m"
end

Termtter.add_hook do |statuses, event|
  colors = %w(0 31 32 33 34 35 36 
              91 92 93 94 95 96)

  case event
  when :update_friends_timeline, :list_friends_timeline, :list_user_timeline
    unless statuses.empty?
      if event == :update_friends_timeline then statuses.reverse! end

      max_screen_name_length = statuses.map{|s|s['user/screen_name'].size}.max

      statuses.each do |s|
        text = s['text'].gsub("\n", '')
        color_num = colors[s['user/screen_name'].hash % colors.size]
        status = "#{s['user/screen_name'].rjust(max_screen_name_length)} #{text}"

        time = Time.local(*ParseDate::parsedate(s['created_at']))
        if event == :list_user_timeline then time_format = '%m-%d %X' else time_format = '%X' end
        time_str = time.strftime(time_format)

        puts "#{color(time_str, 90)} #{color(status, color_num)}"
      end
    end
  when :search
    max_screen_name_length = statuses.map{|s|s['user/screen_name'].size}.max

    statuses.each do |s|
      text = s['text'].gsub("\n", '')
      color_num = colors[s['user/screen_name'].hash % colors.size]
      status = "#{s['user/screen_name'].rjust(max_screen_name_length)} #{text}"
      time = Time.utc(*ParseDate::parsedate(s['created_at'])).localtime
      time_str = time.strftime('%m-%d %X')

      puts "#{color(time_str, 90)} #{color(status, color_num)}"
    end
  end
end

