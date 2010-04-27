Termtter::Client.register_command(
  :name => :ndkn,
  :exec => lambda do |arg|
    n = Termtter::Crypt.crypt(arg)
    puts "ndkned => #{n}"
  end
)
