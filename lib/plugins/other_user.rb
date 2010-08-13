require 'base64'

config.plugins.other_user.set_default(:accounts,{})
config.plugins.other_user.set_default(:tokens_file,"~/.termtter/other_user_tokens")
config.plugins.other_user.set_default(:alias,{})

Termtter::Client.register_command(
  :name => :other_user,
  :alias => :o,
  :help => ['other_user, o','Post by other user'],
  :exec => lambda do |arg_raw|
  tokens =
    if File.exist?(File.expand_path(config.plugins.other_user.tokens_file))
      Marshal.load(
        Base64.decode64(File.read(File.expand_path(
          config.plugins.other_user.tokens_file))))
    else
      {}
    end

    body = arg_raw.split(/ /)
    user_raw = body.shift
    user = config.plugins.other_user.alias[user_raw] || user_raw

    unless tokens[user]
      puts "<on_red>ERROR</on_red> #{user} isn't authorized yet. Starting authorization...".termcolor
      tokens[user] = Termtter::API.authorize_by_oauth(false,false,false)
      open(File.expand_path(config.plugins.other_user.tokens_file), 'w') do |f|
        f.print Base64.encode64(Marshal.dump(tokens))
      end
    end

    at = OAuth::AccessToken.new(
      OAuth::Consumer.new(
        Termtter::Crypt.decrypt(Termtter::CONSUMER_KEY),
        Termtter::Crypt.decrypt(Termtter::CONSUMER_SECRET),
        :site => "http://twitter.com/",
        :proxy => ENV['http_proxy']),
        tokens[user][:token],
        tokens[user][:secret])

    t = OAuthRubytter.new(at, Termtter::API.twitter_option)
    t.update(body.join(' '))

    puts "updated by #{user} => #{body.join(' ')}"
  end
)
