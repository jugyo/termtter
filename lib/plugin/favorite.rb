module Termtter::Client
  add_command %r'^(?:favorite|fav)\s+(\d+)$' do |m,t|
    id = m[1]
    res = t.favorite(id)
    if res.code == '200'
      puts "Favorited status ##{id}"
    else
      puts "Failed: #{res}"
    end
  end

  add_command %r'^(?:favorite|fav)\s+/(.+)$' do |m,t|
    pat = Regexp.new(m[1])
    statuses = public_storage[:log].select { |s| s.text =~ pat }
    if statuses.size == 1
      status = statuses.first
      res = t.favorite(status.id)
      if res.code == '200'
        puts %Q(Favorited "#{status.user_screen_name}: #{status.text}")
      else
        puts "Failed: #{res}"
      end
    else
      puts "#{pat} does not match single status"
    end
  end
end

module Termtter
  class Twitter
    def favorite(id)
      uri = "http://twitter.com/favourings/create/#{id}.json"

      Net::HTTP.start('twitter.com', 80) do |http|
        http.request(post_request(uri))
      end
    end
  end
end
