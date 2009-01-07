# -*- coding: utf-8 -*-

module Termtter

  class Status
    def yharian?
      self.text =~ /^(?:\s|(y\s)|(?:hara\s))+\s*(?:y|(?:hara))(?:\?|!|\.)?\s*$/
    end
  end

  module Client
    add_filter do |statuses|
      statuses.select {|s| s.yharian? }
    end
  end
end

# filter-yhara.rb
#   select Yharian post only

