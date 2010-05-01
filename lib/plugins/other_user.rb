config.plugins.other_user.set_default(:accounts,{})
config.plugins.other_user.set_default(:alias,{})

Termtter::Client.register_command(
  :name => :other_user,
  :alias => :o,
  :help => ['other_user, o','Post by other user'],
  :exec => lambda do |arg_raw|
    body = arg_raw.split(/ /)
    user_raw = body.shift
    user = config.plugins.other_user.alias[user_raw] || user_raw
    Rubytter.new(user,config.plugins.other_user.accounts[user]).update(body.join(' '))
    puts "updated by #{user} => #{body.join(' ')}"
  end
)

