module Termtter::Client
  register_command(
    :name => :follow, :aliases => [],
    :exec_proc => proc {|arg|
      if arg =~ /^(\w+)/
        res = Termtter::API::twitter.social($1.strip, :follow)
        if res.code == '200'
          puts "Followed user @#{$1}"
        else
          puts "Failed: #{res}"
        end
      end
    },
    :completion_proc => proc {|cmd, args|
      find_user_candidates args, "#{cmd} %s"
    },
	:help => ['follow USER', 'Follow user']
  )

  register_command(
    :name => :leave, :aliases => [],
    :exec_proc => proc {|arg|
      if arg =~ /^(\w+)/
        res = t.social($1.strip, :leave)
        if res.code == '200'
          puts "Leaved user @#{$1}"
        else
          puts "Failed: #{res}"
        end
      end
    },
    :completion_proc => proc {|cmd, args|
      find_user_candidates args, "#{cmd} %s"
    },
	:help => ['leave USER', 'Leave user']
  )
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
