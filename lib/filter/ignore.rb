# -*- coding: utf-8 -*-


config.filters.ignore.set_default(:words, [])

module Termtter::Client
  add_filter do |statuses|
    ignore_words = config.filters.ignore.words
    statuses.delete_if do |s|
      ignore_words.any? {|i| i =~ s.text }
    end
  end
end

# filter/ignore.rb
#   ignore words
# setting
#   config.filters.ignore.words = [ /ignore/, /words/ ]

