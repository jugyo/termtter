Termtter::Client.clear_hooks # FIXME: not to clear all but to clear just stdout.rb

# english? :: String -> Boolean
def english?(message)
  /[一-龠]+|[ぁ-ん]+|[ァ-ヴー]+|[ａ-ｚＡ-Ｚ０-９]+/ !~ message
end

# FIXME: The code below is a copy from stdout.rb so it's not DRY. DRY it.
Termtter::Client.add_hook do |statuses, event|
  colors = %w(0 31 32 33 34 35 36 91 92 93 94 95 96)

  case event
  when :update_friends_timeline, :list_friends_timeline, :list_user_timeline, :show, :replies
    unless statuses.empty?
      if event == :update_friends_timeline then statuses = statuses.reverse end
      statuses.each do |s|
        text = s.text.gsub("\n", '')
        next unless english?(text) # if you substitute "if" for "unless", this script will be "japanese.rb"
        color_num = colors[s.user_screen_name.hash % colors.size]
        status = "#{s.user_screen_name}: #{text}"
        if s.in_reply_to_status_id
          status += " (reply to #{s.in_reply_to_status_id})"
        end

        case event
        when :update_friends_timeline, :list_friends_timeline
          time_format = '%H:%M:%S'
        else
          time_format = '%m-%d %H:%d'
        end
        time_str = "(#{s.created_at.strftime(time_format)})"

        puts "#{color(time_str, 90)} #{color(status, color_num)}"
      end
    end
  when :search
    statuses.each do |s|
      text = s.text.gsub("\n", '')
      color_num = colors[s.user_screen_name.hash % colors.size]
      status = "#{s.user_screen_name}: #{text}"
      time_str = "(#{s.created_at.strftime('%m-%d %H:%d')})"

      puts "#{color(time_str, 90)} #{color(status, color_num)}"
    end
  end
end

# USAGE:
#   Write the line on the *first line* of your ~/.termtter
#     require 'plugin/english'
#   (english.rb will destroy plugins which were required before)
