# -*- coding: utf-8 -*-

Thread.start do
  100.times do |i|
    Twitter::API.twitter.update(
      "I decided not to use twitter so as not to leave university before I complete the dissertation#{i.odd? ? '!' : '.'}")
  end
end
