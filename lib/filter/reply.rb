# -*- coding: utf-8 -*-

Termtter::Client.add_filter do |statuses|
  statuses.select{|s| s.text =~ /@/ }
end

# filter-reply.rb
#   select @ reply post only
