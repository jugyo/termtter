require 'parsedate'

def color(str, num)
  "\e[#{num}m#{str}\e[0m"
end

Termtter.add_hook do |statuses, event|
  colors = %w(0 31 32 33 34 35 36 
              91 92 93 94 95 96)

  case event
  when :update_friends_timeline, :list_friends_timeline, :list_user_timeline, :show
    unless statuses.empty?
      if event == :update_friends_timeline then statuses.reverse! end
      statuses.each do |s|
        text = s['text'].gsub("\n", '')
        color_num = colors[s['user/screen_name'].hash % colors.size]
        status = "#{s['user/screen_name']}: #{text}"

        time = Time.utc(*ParseDate::parsedate(s['created_at'])).localtime
        if event == :list_user_timeline
          time_format = '%m-%d %H:%d'
        else
          time_format = '%H:%d:%S'
        end
        time_str = "(#{time.strftime(time_format)})"

        puts "#{color(time_str, 90)} #{color(status, color_num)}"
      end
    end
  when :search
    statuses.each do |s|
      text = s['text'].gsub("\n", '')
      color_num = colors[s['user/screen_name'].hash % colors.size]
      status = "#{s['user/screen_name']}: #{text}"
      
      time = Time.utc(*ParseDate::parsedate(s['created_at'])).localtime
      time_str = "(#{time.strftime('%m-%d %H:%d')})"

      puts "#{color(time_str, 90)} #{color(status, color_num)}"
    end
  end
end

