# -*- coding: utf-8 -*-

module Termtter::Client
  add_filter do |statuses|
    statuses.map do |s|
      s.text = s.text.split(//).reverse.to_s
      s
    end
  end
end

# filter-reverse.rb
#   reverse texts
