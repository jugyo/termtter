100.times do
  Thread.start do
    Termtter::Twitter.new(configatron.user_name, configatron.password).update_status("I decided not to use twitter so as not to leave university before I complete the dissertation.")
  end
  sleep 5
end
