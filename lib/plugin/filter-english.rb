# -*- coding: utf-8 -*-

# english? :: String -> Boolean
def english?(message)
  /[一-龠]+|[ぁ-ん]+|[ァ-ヴー]+|[ａ-ｚＡ-Ｚ０-９]+/ !~ message
end


module Termtter::Client
  add_filter do |statuses|
    statuses.select do |s|
      english? s.text
    end
  end
end

# filter-english.rb
#   select English post only
