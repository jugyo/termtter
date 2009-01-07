# -*- coding: utf-8 -*-

module Termtter
  module Client
    add_filter do |statuses|
      statuses.select do |s|
        Status.english? s.text
      end
    end
  end
end

# filter-english.rb
#   select English post only
