# -*- coding: utf-8 -*-

require 'tmpdir'
require 'open-uri'
require 'uri'
require 'fileutils'
require 'cgi'

begin
  require 'meow'
  growl = Meow.new('termtter', 'update_friends_timeline')
rescue LoadError
  growl = nil
end

config.plugins.growl.set_default(:icon_cache_dir, "#{Termtter::CONF_DIR}/tmp/user_profile_images")
config.plugins.growl.set_default(:growl_user, [])
config.plugins.growl.set_default(:growl_keyword, [])
FileUtils.mkdir_p(config.plugins.growl.icon_cache_dir) unless File.exist?(config.plugins.growl.icon_cache_dir)
unless File.exist?("#{config.plugins.growl.icon_cache_dir}/default.png")
  File.open("#{config.plugins.growl.icon_cache_dir}/default.png", "wb") do |f|
    f << open("http://static.twitter.com/images/default_profile_normal.png").read # TODO: use Termtter::API.connection
  end
end

def get_icon_path(s)
  Dir.mkdir_p(config.plugins.growl.icon_cache_dir) unless File.exists?(config.plugins.growl.icon_cache_dir)

  /http:\/\/.+\/(\d+)\/.*?$/ =~ s.user.profile_image_url
  cache_file = "%s/%s-%s%s" % [  config.plugins.growl.icon_cache_dir,
                                 s.user.screen_name,
                                 $+,
                                 File.extname(s.user.profile_image_url)  ]
  unless File.exist?(cache_file)
    Thread.new(s,cache_file) do |s,cache_file|
      Dir.glob("#{config.plugins.growl.icon_cache_dir}/#{s.user.screen_name}-*") {|f| File.delete(f) }
      begin
        File.open(cache_file, "wb") do |f|
          f << open(URI.escape(s.user.profile_image_url)).read
        end
      rescue OpenURI::HTTPError
        cache_file = "#{config.plugins.growl.icon_cache_dir}/default.png"
      end
    end
  end
  return cache_file
end

def is_growl(s)
  return true if config.plugins.growl.growl_user.empty? && config.plugins.growl.growl_keyword.empty?
  if config.plugins.growl.growl_user.include?(s.user.screen_name) ||
      Regexp.union(config.plugins.growl.growl_keyword) =~ s.text
    return true
  else
    return false
  end
end

Termtter::Client.register_hook(
  :name => :growl2,
  :points => [:output],
  :exec_proc => lambda {|statuses, event|
    return unless event == :update_friends_timeline
    Thread.start do
      statuses.each do |s|
        next unless is_growl(s)
        growl_title = s.user.screen_name
        growl_title += " (#{s.user.name})" unless s.user.screen_name == s.user.name
        unless growl
          system 'growlnotify', growl_title, '-m', s.text.gsub("\n",''), '-n', 'termtter', '--image', get_icon_path(s)
        else
          begin
            icon = Meow.import_image(get_icon_path(s))
          rescue
            icon = Meow.import_image("#{config.plugins.growl.icon_cache_dir}/default.png")
          end
          growl.notify(growl_title, CGI.unescape(CGI.unescapeHTML(s.text)), :icon => icon) do
            s.text.gsub(URI.regexp) {|uri| system "open #{uri}"}
          end
        end
        sleep 0.1
      end
    end
  }
)
