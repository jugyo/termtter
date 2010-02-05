# -*- coding: utf-8 -*-
require 'fileutils'
config.plugins.notify_send.set_default(
  :icon_cache_dir, "#{Termtter::CONF_DIR}/tmp/user_profile_images")

FileUtils.mkdir_p(config.plugins.notify_send.icon_cache_dir) unless
  File.exist?(config.plugins.notify_send.icon_cache_dir)
Dir.glob("#{config.plugins.notify_send.icon_cache_dir}/*") {|f|
  File.delete(f) unless File.size?(f) }
unless File.exist?("#{config.plugins.notify_send.icon_cache_dir}/default.png")
  File.open(
    "#{config.plugins.notify_send.icon_cache_dir}/default.png", "wb") do |f|
    f << open(
      "http://static.twitter.com/images/default_profile_normal.png").read
  end
end

def get_icon_path(s)
  /https?:\/\/.+\/(\d+)\/.*?$/ =~ s.user.profile_image_url
  cache_file = "%s/%s-%s%s" % [
    config.plugins.notify_send.icon_cache_dir,
    s.user.screen_name,
    $+,
    File.extname(s.user.profile_image_url)]
  unless File.exist?(cache_file)
    Thread.new(s,cache_file) do |s,cache_file|
      Dir.glob(
        "#{config.plugins.notify_send.icon_cache_dir}/#{s.user.screen_name}-*") {|f|
        File.delete(f)
      }
      begin
        s.user.profile_image_url.sub!(/^https/,'http')
        File.open(cache_file, 'wb') do |f|
          f << open(URI.escape(s.user.profile_image_url)).read
        end
      rescue OpenURI::HTTPError
        cache_file =
          "#{config.plugins.notify_send.icon_cache_dir}/default.png"
      end
    end
  end
  return cache_file
end

Termtter::Client.register_hook(
  :name => :notify_send2,
  :points => [:output],
  :exec_proc => lambda {|statuses, event|
    return unless event == :update_friends_timeline
    Thread.start do
      statuses.each do |s|
        text = CGI.escapeHTML(s.text)
        text.gsub!(
          %r{https?://[-_.!~*\'()a-zA-Z0-9;\/?:\@&=+\$,%#]+},
          '<a href="\0">\0</a>')
        Termtter::Client.notify(s.user.screen_name, text)
        sleep 0.1
      end
    end
  }
)
