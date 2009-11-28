# -*- coding: utf-8 -*-
require 'fileutils'
require 'RMagick' # apt-get install librmagick-ruby
require 'uri'
require 'open3'
require 'terminfo'

# TODO should be DRY: Copy from notify-send3.rb
config.plugins.notify_send.set_default(:icon_cache_dir, "#{Termtter::CONF_DIR}/tmp/user_profile_images")
def get_icon_path(s)
  FileUtils.mkdir_p(config.plugins.notify_send.icon_cache_dir) unless File.exist?(config.plugins.notify_send.icon_cache_dir)
  cache_file = "%s/%s%s" % [  config.plugins.notify_send.icon_cache_dir,
                              s.user.screen_name,
                              File.extname(s.user.profile_image_url)  ]
  if !File.exist?(cache_file) || (File.atime(cache_file) + 24*60*60) < Time.now
    File.open(cache_file, "wb") do |f|
      begin
        http_class = Net::HTTP
        unless config.proxy.host.nil? or config.proxy.host.empty?
          http_class = Net::HTTP::Proxy(config.proxy.host,
                                        config.proxy.port,
                                        config.proxy.user_name,
                                        config.proxy.password)
        end
        uri = URI.parse(URI.escape(s.user.profile_image_url))
        image = http_class.get(uri.host, uri.path, uri.port)
        rimage = Magick::Image.from_blob(image).first
        rimage = rimage.resize_to_fill(48, 48)
        f << rimage.to_blob
      rescue Net::ProtocolError
        return nil
      end
    end
  end
  cache_file
end

module Termtter::Client

  W3MIMG = '/usr/lib/w3m/w3mimgdisplay'
  W3MIMGSTDIN, stdout, stderr = *Open3.popen3(W3MIMG)

  sizestr = `#{W3MIMG} -test`.chomp
  PW, PH = sizestr.split.map(&:to_i)
  CH, CW = TermInfo.screen_size()
  LINEH = PH / CH
  @w3mimgicons = []

  register_hook(
    :name => :w3mimg,
    :points => [:output],
    :exec_proc => lambda {|statuses, event|
      return unless event == :update_friends_timeline
      Thread.start do
        newicons = statuses.reverse.map do |s|
          lines = s.text.count("\n") + 1
          file = get_icon_path(s)
          [file, lines]
        end
        @w3mimgicons = (newicons + @w3mimgicons).take(CH)
        sleep 0.5
        w, h = 48, 48
        x = PW - w
        y = PH - LINEH
        @w3mimgicons.each do |i|
          file, lines = i
          sh = LINEH * lines
          y -= sh
          W3MIMGSTDIN.print "2;3;\n0;1;#{x};#{y};#{w};#{h};0;0;0;#{sh};#{file}\n4\n3;\n"
          break if y <= 0
        end
      end
    }
  )

end
