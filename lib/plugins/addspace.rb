# -*- coding: utf-8 -*-

config.plugins.addspace.set_default( :before, [ %r{https?://} ] )
config.plugins.addspace.set_default( :after, %w{ ★ ☆ △ ▽ … })

module Termtter::Client
  add_filter do |statuses, event|
    statuses.each do |s|
      config.plugins.addspace.before.each do |c|
        s.text.gsub!(/(?=\S)(#{c})/, ' \1' )
      end
    end
    statuses.each do |s|
      config.plugins.addspace.after.each do |c|
        s.text.gsub!(/(#{c})(?=\S)/, '\1 ' )
      end
      statuses
    end
  end
end
# addspace
#   add space before or after specified words.
# example:
#   before: ABCDEhttp://~~~
#   after:  ABCDE http://~~~
#   before: ★★★
#   after:  ★ ★ ★ 
