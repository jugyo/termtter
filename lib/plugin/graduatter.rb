twitter = Termtter::Twitter.new(configatron.user_name, configatron.password)
Thread.start do
  100.times do |i|
    flg = i % 2 == 0
    twitter.update_status("I decided not to use twitter so as not to leave university before I complete the dissertation#{flg ? '!' : '.'}")
  end
end
