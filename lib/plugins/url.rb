def url_by_tweet(t)
  "http://twitter.com/#{t.user.screen_name}/status/#{t.id}"
end

Termtter::Client.register_command(:name => :url,
                                  :exec => lambda do |arg|
  t = Termtter::API.twitter.show(arg)
  puts url_by_tweet(t)
end)


