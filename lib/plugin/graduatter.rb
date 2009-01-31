# -*- coding: utf-8 -*-

twitter = Termtter::Twitter.new(configatron.user_name, configatron.password)

Thread.start do

  100.times do |i|

    twitter.update_status(

      "I decided not to use twitter so as not to leave university before I complete the dissertation#{i.odd? ? '!' : '.'}")

  end

end
