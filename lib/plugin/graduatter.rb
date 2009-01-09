100.times do
  Termtter::Twitter.new(configatron.user_name, configatron.password).update_status("I decided not to use twitter so as not to leave university before I complete the dissertation.")
end
