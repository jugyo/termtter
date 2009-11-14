# -*- coding: utf-8 -*-

config.plugins.gsub.set_default(:table, [
  [/([★☆△▽…□♪♬])(?=\S)/, '\1 '],
  [/(?=\S)(https?:\/\/)/, ' \1'],
])

Termtter::Client.register_hook(
  :name => :gsub,
  :point => :filter_for_output,
  :exec => lambda {|statuses, event|
    statuses.each do |s|
      t = s.text
      config.plugins.gsub.table.each {|a, b| t.gsub!(a, b || '') }
    end
  }
)
