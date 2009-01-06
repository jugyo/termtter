require 'tmpdir'
require 'open-uri'
require 'uri'

configatron.plugins.growl.set_default(:icon_cache_dir, "#{Dir.tmpdir}/termtter-icon-cache-dir")
Dir.mkdir_p(configatron.plugins.growl.icon_cache_dir) unless File.exist?(configatron.plugins.growl.icon_cache_dir)

def get_icon_path(s)
  cache_file = "%s/%s%s" % [  configatron.plugins.growl.icon_cache_dir, 
                              s.user_screen_name, 
                              File.extname(s.user_profile_image_url)  ]
  if File.exist?(cache_file) && (File.atime(cache_file) + 24*60*60) > Time.now
    return cache_file
  else
    Thread.new do
      File.open(cache_file, "wb") do |f|
        f << open(URI.escape(s.user_profile_image_url)).read
      end
    end
    return nil
  end
end

queue = []
Thread.new do
  loop do
    begin
      if s = queue.pop
        arg = ['growlnotify', s.user_screen_name, '-m', s.text.gsub("\n",''), '-n', 'termtter']
        #icon_path = get_icon_path(s)
        #arg += ['--image', icon_path] if icon_path
        system *arg
      end
    rescue => e
      puts e
      puts e.backtrace.join("\n")
    end
    sleep 0.1
  end
end

Termtter::Client.add_hook do |statuses, event|
  if !statuses.empty? && event == :update_friends_timeline
    statuses.reverse.each do |s|
      queue << s
    end
  end
end
