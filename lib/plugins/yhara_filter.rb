# -*- coding: utf-8 -*-

Termtter::Client.add_filter do |statuses|
  statuses.select{|s| s.text =~ /^(?:\s|(y\s)|(?:hara\s))+\s*(?:y|(?:hara))(?:\?|!|\.)?\s*$/ }
end

# yhara_filter.rb
#   select Yharian post only
