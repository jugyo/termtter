# -*- coding: utf-8 -*-

require 'fileutils'
require 'RMagick'

# Copy from notify-send2.rb
config.plugins.notify_send.set_default(:icon_cache_dir, "#{Termtter::CONF_DIR}/tmp/user_profile_images")
def get_icon_path(s)
  FileUtils.mkdir_p(config.plugins.notify_send.icon_cache_dir) unless File.exist?(config.plugins.notify_send.icon_cache_dir)
  cache_file = "%s/%s%s" % [  config.plugins.notify_send.icon_cache_dir,
                              s.user.screen_name,
                              File.extname(s.user.profile_image_url)  ]
  if !File.exist?(cache_file) || (File.atime(cache_file) + 24*60*60) < Time.now
    File.open(cache_file, "wb") do |f|
      begin
        image  = open(URI.escape(s.user.profile_image_url)).read
        rimage = Magick::Image.from_blob(image).first
        rimage = rimage.resize_to_fill(48, 48)
        f << rimage.to_blob
      rescue OpenURI::HTTPError
        return nil
      end
    end
  end
  cache_file
end

Termtter::Client.register_hook(
  :name => :notify_send3,
  :points => [:output],
  :exec_proc => lambda {|statuses, event|
    return unless event == :update_friends_timeline
    Thread.start do
      statuses.each do |s|
        text = CGI.escapeHTML(s.text)
        text.gsub!(%r{https?://[-_.!~*\'()a-zA-Z0-9;\/?:\@&=+\$,%#]+},'<a href="\0">\0</a>')
        system 'notify-send', s.user.screen_name, text, '-i', get_icon_path(s)
        sleep 0.1
      end
    end
  }
)

# notify-send3.rb
#   caching resized profile image.
