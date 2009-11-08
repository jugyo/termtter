# -*- coding: utf-8 -*-

Termtter::Client.register_hook(
  :name => :reverse,
  :point => :filter_for_output,
  :exec => lambda {|statuses, event|
    statuses.each do |s|
      s.text = s.text.split(//).reverse.to_s
    end
  }
)

# filter-reverse.rb
#   reverse texts
