# -*- coding: utf-8 -*-



configatron.filters.ignore.set_default(:words, [])



module Termtter::Client

  add_filter do |statuses|

    ignore_words = configatron.filters.ignore.words

    statuses.delete_if do |s|

      ignore_words.any? {|i| i =~ s.text }

    end

  end

end



# filter/ignore.rb

#   ignore words

# setting

#   configatron.filters.ignore.words = [ /ignore/, /words/ ]


