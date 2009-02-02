# -*- coding: utf-8 -*-

module Termtter::Client
  add_filter do |statuses|
    statuses.each do |s|
      s.text.gsub!(/(\S)(https?:\/\/)/, '\1 \2')
    end
    statuses
  end
end
