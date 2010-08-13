# -*- coding: utf-8 -*-
# vim: set fenc=utf-8

module Termtter::English
  # call-seq:
  #   english? :: String -> Boolean
  def self.english?(message)
    /[一-龠]+|[ぁ-ん]+|[ァ-ヴー]+|[ａ-ｚＡ-Ｚ０-９]+/ !~ message
  end
end

Termtter::Client.add_filter do |statuses, event|
  config.plugins.english.set_default(:only, [])
  statuses.select {|i|
    !config.plugins.english.only.include?(event) ||
      Termtter::English.english?(i.text)
  }
end

# english_filter.rb
#   select English posts only
#
# config sample:
#   t.plug 'english'
# or,
#   t.plug 'english', :only => [:list_friends_timeline, :update_friends_timeline]
