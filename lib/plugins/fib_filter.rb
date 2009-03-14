# -*- coding: utf-8 -*-

def fib(n)i=0;j=1;n.times{j=i+i=j};i end
module Termtter::Client
  add_filter do |statuses|
    statuses.each do |s|
      s.text.gsub!(/(\d+)/) do |m|
        n = $1.to_i
        n < 1000000000 ? fib(n) : n # not to calc fib(id)
      end
    end
    statuses
  end
end
