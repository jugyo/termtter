# -*- coding: utf-8 -*-

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
config.plugins.growl.set_default(:priority_veryhigh_user, [])
config.plugins.growl.set_default(:priority_high_user, [])
config.plugins.growl.set_default(:priority_normal_user, [])
config.plugins.growl.set_default(:priority_low_user, [])
config.plugins.growl.set_default(:priority_verylow_user, [])
config.plugins.growl.set_default(:priority_veryhigh_keyword, [])
config.plugins.growl.set_default(:priority_high_keyword, [])
config.plugins.growl.set_default(:priority_normal_keyword, [])
config.plugins.growl.set_default(:priority_low_keyword, [])
config.plugins.growl.set_default(:priority_verylow_keyword, [])
config.plugins.growl.set_default(:sticky_user, [])
config.plugins.growl.set_default(:sticky_keyword, [])
growl_keys    = { 'user'    =>  config.plugins.growl.growl_user,
                  'keyword' =>  Regexp.union(config.plugins.growl.growl_keyword) }
priority_keys = { 'user'    => [config.plugins.growl.priority_veryhigh_user,
                                config.plugins.growl.priority_high_user,
                                config.plugins.growl.priority_normal_user,
                                config.plugins.growl.priority_low_user,
                                config.plugins.growl.priority_verylow_user],
                  'keyword' => [Regexp.union(config.plugins.growl.priority_veryhigh_keyword),
                                Regexp.union(config.plugins.growl.priority_high_keyword),
                                Regexp.union(config.plugins.growl.priority_normal_keyword),
                                Regexp.union(config.plugins.growl.priority_low_keyword),
                                Regexp.union(config.plugins.growl.priority_verylow_keyword) ] }
sticky_keys   = { 'user'    =>  config.plugins.growl.sticky_user,
                  'keyword' =>  Regexp.union(config.plugins.growl.sticky_keyword) }

FileUtils.mkdir_p(config.plugins.growl.icon_cache_dir) unless File.exist?(config.plugins.growl.icon_cache_dir)
Dir.glob("#{config.plugins.growl.icon_cache_dir}/*") {|f| File.delete(f) unless File.size?(f) }
unless File.exist?("#{config.plugins.growl.icon_cache_dir}/default.png")
  File.open("#{config.plugins.growl.icon_cache_dir}/default.png", "wb") do |f|
    f << open("http://static.twitter.com/images/default_profile_normal.png").read
  end
end

def get_icon_path(s)
  /https?:\/\/.+\/(\d+)\/.*?$/ =~ s.user.profile_image_url
  cache_file = "%s/%s-%s%s" % [  config.plugins.growl.icon_cache_dir,
                                 s.user.screen_name,
                                 $+,
                                 File.extname(s.user.profile_image_url)  ]
  unless File.exist?(cache_file)
    Thread.new(s,cache_file) do |s,cache_file|
      Dir.glob("#{config.plugins.growl.icon_cache_dir}/#{s.user.screen_name}-*") {|f| File.delete(f) }
      begin
        s.user.profile_image_url.sub!(/^https/,'http')
        File.open(cache_file, 'wb') do |f|
          f << open(URI.escape(s.user.profile_image_url)).read
        end
      rescue OpenURI::HTTPError
        cache_file = "#{config.plugins.growl.icon_cache_dir}/default.png"
      end
    end
  end
  return cache_file
end

def get_priority(s,priority_keys)
  priority = 2
  5.times {|n|
    return priority.to_s if priority_keys['user'][n].include?(s.user.screen_name) ||
                            priority_keys['keyword'][n] =~ s.text
    priority -= 1
  }
  return '0'
end

def is_growl(s,growl_keys)
  return true if (growl_keys['user'].empty? && growl_keys['keyword'] == /(?!)/) ||
                 (growl_keys['user'].include?(s.user.screen_name) || growl_keys['keyword'] =~ s.text)
  return false
end

def is_sticky(s,sticky_keys)
  return true if sticky_keys['user'].include?(s.user.screen_name) || sticky_keys['keyword'] =~ s.text
  return false
end

Termtter::Client.register_hook(
  :name => :growl2,
  :points => [:output],
  :exec_proc => lambda {|statuses, event|
    return unless event == :update_friends_timeline
    Thread.start do
      statuses.each do |s|
        next unless is_growl(s,growl_keys)
        growl_title = s.user.screen_name
        growl_title += " (#{s.user.name})" unless s.user.screen_name == s.user.name
        unless growl
          arg = ['growlnotify', growl_title, '-m', s.text.gsub("\n",''), '-n', 'termtter', '-p', get_priority(s,priority_keys), '--image', get_icon_path(s)]
          arg.push('-s') if is_sticky(s,sticky_keys)
          system *arg
        else
          begin
            icon = Meow.import_image(get_icon_path(s))
          rescue
            icon = Meow.import_image("#{config.plugins.growl.icon_cache_dir}/default.png")
          end
          growl.notify(growl_title, CGI.unescape(CGI.unescapeHTML(s.text)),
                       {:icon => icon,
                        :priority => get_priority(s,priority_keys),
                        :sticky => is_sticky(s,sticky_keys) }) do
            s.text.gsub(URI.regexp) {|uri| system "open #{uri}"}
          end
        end
        sleep 0.1
      end
    end
  }
)
#Optional setting example.
#  Growl ON setting.
#    config.plugins.growl.growl_user    = ['p2pquake', 'jihou']
#    config.plugins.growl.growl_keyword = ['地震', /^@screen_name/]
#  Priority setting.
#    config.plugins.growl.priority_veryhigh_user    = ['veryhigh_user']
#    config.plugins.growl.priority_veryhigh_keyword = ['veryhigh_keyword', /^@screen_name']
#    config.plugins.growl.priority_high_user        = ['high_user']
#    config.plugins.growl.priority_high_keyword     = ['high_keyword']
#    config.plugins.growl.priority_low_user         = ['low_user']
#    config.plugins.growl.priority_low_keyword      = ['low_keyword']
#    config.plugins.growl.priority_verylow_user     = ['verylow_user']
#    config.plugins.growl.priority_verylow_keyword  = ['verylow_keyword']
#  Sticky setting.
#    config.plugins.growl.sticky_user    = ['screen_name']
#    config.plugins.growl.sticky_keyword = [/^@screen_name/, '#termtter']
