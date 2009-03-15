# -*- coding: utf-8 -*-
# vim: set fenc=utf-8

module Termtter::English
  # english? :: String -> Boolean
  def self.english?(message)
    /[一-龠]+|[ぁ-ん]+|[ァ-ヴー]+|[ａ-ｚＡ-Ｚ０-９]+/ !~ message
  end
end

Termtter::Client.add_filter do |statuses, event|
  statuses.select {|i|
    event != config.plugins.english.only ||
      Termtter::English.english?(i.text)
  }
end

# english_filter.rb
#   select English posts only
#
# config sample:
#   plugin 'english'
# or,
#   plugin 'english', :only => :update_friends_timeline
