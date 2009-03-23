# -*- coding: utf-8 -*-

require 'tmpdir'
require 'open-uri'
require 'uri'
require 'fileutils'

begin
  require 'ruby-growl'
  growl = Growl.new "localhost", "termtter", "termtter status notification"
rescue LoadError
  growl = nil
end

config.plugins.growl.set_default(:icon_cache_dir, "#{Termtter::CONF_DIR}/tmp/user_profile_images")
FileUtils.mkdir_p(config.plugins.growl.icon_cache_dir) unless File.exist?(config.plugins.growl.icon_cache_dir)

def get_icon_path(s)
  Dir.mkdir_p(config.plugins.growl.icon_cache_dir) unless File.exists?(config.plugins.growl.icon_cache_dir)
  cache_file = "%s/%s%s" % [  config.plugins.growl.icon_cache_dir, 
                              s.user.screen_name, 
                              File.extname(s.user.profile_image_url)  ]
  if !File.exist?(cache_file) || (File.atime(cache_file) + 24*60*60) < Time.now
    File.open(cache_file, "wb") do |f|
      f << open(URI.escape(s.user.profile_image_url)).read
    end
  end
  cache_file
end

Termtter::Client.register_hook(
  :name => :growl,
  :points => [:output],
  :exec_proc => lambda {|statuses, event|
    return unless event == :update_friends_timeline
    Thread.start do
      statuses.each do |s|
        unless growl
          arg = ['growlnotify', s.user.screen_name, '-m', s.text.gsub("\n",''), '-n', 'termtter']
          icon_path = get_icon_path(s)
          arg += ['--image', icon_path] if icon_path
          system *arg
        else
          growl.notify "termtter status notification", s.text, s.user.screen_name
        end
        sleep 0.1
      end
    end
  }
)
