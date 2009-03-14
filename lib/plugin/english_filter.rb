# -*- coding: utf-8 -*-

Termtter::Client.add_filter do |statuses|
  statuses.select{|s| s.english? }
end

# english_filter.rb
#   select English post only
