module Termtter::Client
  add_help 'follow @USER', 'Follow user'

  add_command %r'^follow\s+(\w+)$' do |m, t|
    user = m[1]
    res = t.follow(user)
    if res.code == '200'
      puts "Followed user @#{user}"
    else
      puts "Failed: #{res}"
    end
  end

  add_help 'leave @USER', 'Leave user'

  add_command %r'^leave\s+(\w+)$' do |m, t|
    user = m[1]
    res = t.leave(user)
    if res.code == '200'
      puts "Leaved user @#{user}"
    else
      puts "Failed: #{res}"
    end
  end

  add_completion do |input|
    case input
    when /^(follow|leave)?\s+(.*)/
      find_user_candidates $2, "#{$1} %s"
    else
      %w[follow leave].grep(/^#{Regexp.quote input}/)
    end
  end
end

module Termtter
  class Twitter
    def follow(user)
      uri = "http://twitter.com/friendships/create/#{user}.json"

      Net::HTTP.start('twitter.com', 80) do |http|
        http.request(post_request(uri))
      end
    end

    def leave(user)
      uri = "http://twitter.com/friendships/destroy/#{user}.json"

      Net::HTTP.start('twitter.com', 80) do |http|
        http.request(post_request(uri))
      end
    end
  end
end
