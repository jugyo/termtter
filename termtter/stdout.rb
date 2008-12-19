Termtter.add_hook do |statuses|
  unless statuses.empty?
    puts "\e[#{100}m#{Time.now.strftime('%X')}\e[0m"
    
    colors = %w(0 31 32 33 34 35 36 
                91 92 93 94 95 96)
    
    statuses.reverse.each do |s|
      text = s['text'].gsub("\n", '').split(//u)
      color_num = colors[s['user/screen_name'].hash % colors.size]
      status = "#{s['user/screen_name'].rjust(16)} #{text}"
      puts "\e[#{color_num}m#{status}\e[0m"
    end
  end
end
