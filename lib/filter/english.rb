# -*- coding: utf-8 -*-

Termtter::Client.add_filter do |statuses|
  statuses.select &:english?
end

# filter-english.rb
#   select English post only
