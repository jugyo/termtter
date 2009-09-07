# -*- coding: utf-8 -*-

config.filters.ignore.set_default(:words, [])

module Termtter::Client
  register_hook(
    :name => :ignore,
    :point => :filter_for_output,
    :exec => lambda { |statuses, event|  
      ignore_words = config.filters.ignore.words
      statuses.delete_if do |s|
        ignore_words.any? do |word|
          word = /#{Regexp.quote(word)}/ if word.kind_of? String
          word =~ s.text
        end
      end
    }
  )
end

# filter/ignore.rb
#   ignore words
# setting
#   config.filters.ignore.words = [ /ignore/, /words/ ]

