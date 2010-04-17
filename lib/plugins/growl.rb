# -*- coding: utf-8 -*-

require 'tmpdir'
require 'open-uri'
require 'uri'
require 'fileutils'
require 'cgi'

begin
  require 'ruby-growl'
  if RUBY_VERSION >= "1.9" # Fix ruby-growl for multibyte chars if Ruby version is over 1.9
    class Growl
      private

      def notification_packet(name, title, description, priority, sticky)
        flags = 0
        data = []

        packet = [
          GROWL_PROTOCOL_VERSION,
          GROWL_TYPE_NOTIFICATION,
        ]

        flags = 0
        flags |= ((0x7 & priority) << 1) # 3 bits for priority
        flags |= 1 if sticky # 1 bit for sticky

        packet << flags
        packet << name.bytesize
        packet << title.bytesize
        packet << description.bytesize
        packet << @app_name.bytesize

        data << name
        data << title
        data << description
        data << @app_name

        packet << data.join
        packet = packet.pack GNN_FORMAT

        checksum = MD5.new packet
        checksum.update @password unless @password.nil?

        packet << checksum.digest

        return packet.force_encoding('utf-8')
      end

      def send(packet)
        set_sndbuf packet.bytesize
        @socket.send packet, 0
        @socket.flush
      end
    end
  end

  growl = Growl.new "localhost", "termtter", ["update_friends_timeline"]
rescue LoadError
  growl = nil
end

config.plugins.growl.set_default(:sticky, false)
config.plugins.growl.set_default(:priority, 0)
config.plugins.growl.set_default(:icon_cache_dir, "#{Termtter::CONF_DIR}/tmp/user_profile_images")
FileUtils.mkdir_p(config.plugins.growl.icon_cache_dir) unless File.exist?(config.plugins.growl.icon_cache_dir)

def get_icon_path(s)
  Dir.mkdir_p(config.plugins.growl.icon_cache_dir) unless File.exists?(config.plugins.growl.icon_cache_dir)
  cache_file = "%s/%s%s" % [  config.plugins.growl.icon_cache_dir, 
                              s.user.screen_name, 
                              File.extname(s.user.profile_image_url)  ]
  if !File.exist?(cache_file) || (File.atime(cache_file) + 24*60*60) < Time.now
    File.open(cache_file, "wb") do |f|
      begin
        f << open(URI.escape(s.user.profile_image_url)).read
      rescue OpenURI::HTTPError
        return nil
      end
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
          # TODO: Add option for priority and sticky
          system 'growlnotify', s.user.screen_name, '-m', s.text.gsub("\n",''), '-n', 'termtter', '--image', get_icon_path(s)
        else
          begin
          growl.notify(
            "update_friends_timeline",
            s.user.screen_name,
            CGI.unescapeHTML(s.text),
            config.plugins.growl.priority,
            config.plugins.growl.sticky
          )
          rescue Errno::ECONNREFUSED
          end
        end
        sleep 0.1
      end
    end
  }
)
