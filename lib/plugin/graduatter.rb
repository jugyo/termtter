# -*- coding: utf-8 -*-

twitter = Termtter::Twitter.new(config.user_name, config.password)
Thread.start do
  100.times do |i|
    twitter.update_status(
      "I decided not to use twitter so as not to leave university before I complete the dissertation#{i.odd? ? '!' : '.'}")
  end
end
