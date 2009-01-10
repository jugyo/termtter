module Termtter::Client
  add_help 'follow USER', 'Follow user'
  add_help 'leave USER', 'Leave user'

  add_command %r'^(follow|leave)\s+(\w+)\s*$' do |m, t|
    user = m[2]
    res = t.social(user, m[1].to_sym)
    if res.code == '200'
      puts "#{m[1].capitalize}ed user @#{user}"
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
    def social(user, type)
      type =
        case type.to_sym
        when :follow then 'create'
        when :leave  then 'destroy'
        end
      uri = "#{@connection.protocol}://twitter.com/friendships/#{type}/#{user}.json"

      @connection.start('twitter.com', @connection.port) do |http|
        http.request(post_request(uri))
      end
    end
  end
end
