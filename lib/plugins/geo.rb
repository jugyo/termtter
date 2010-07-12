# -*- coding: utf-8 -*-
config.plugins.geo.set_default(:url, 'http://www.openstreetmap.org/?lat=%s&lon=%s&zoom=18')
# other setting example: 'http://maps.google.co.jp/maps?q=%s,%s'

Termtter::Client.register_hook(
  :name => :geo,
  :points => [:output],
  :exec_proc => lambda {|statuses, event|
    config.plugins.geo.path
    if event == :show
      statuses.each do |s|
        next unless s.geo
        next if s.geo[:type] != 'Point'
        open_browser(config.plugins.geo.url % s.geo.coordinates)
      end
    end
  }
)

# geo.rb:
# show the location of the tweet
