# -*- coding: utf-8 -*-

Termtter::Client.add_filter do |statuses|
  statuses.select{|s| s.english? }
end

# filter-english.rb
#   select English post only
