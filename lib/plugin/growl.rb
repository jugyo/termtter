require 'tmpdir'
require 'uri'

def get_icon_path(s)
  cache_dir = "#{Dir.tmpdir}/termtter-icon-cache-dir"
  cache_file = "#{cache_dir}/#{s.user_id}"
  unless File.exist?(cache_file)
    Dir.mkdir(cache_dir) unless File.exist?(cache_dir)
    buf = ""
    File.open(URI.encode(s.user_profile_image_url)) do |f|
      buf = f.read
    end
    File.open(cache_file, "w") do |f|
      f.write(buf)
    end
  end
  cache_file
end

Termtter::Client.add_hook do |statuses, event|
  if !statuses.empty? && event == :update_friends_timeline
    statuses.reverse.each do |s|
      text = s.text.gsub("\n",'')
      icon_path = get_icon_path(s)
      system 'growlnotify', s.user_screen_name, '-m', text,
        '-n', 'termtter', '--image', icon_path
    end
  end
end
