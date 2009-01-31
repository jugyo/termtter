require 'highline'
require 'time'

module Termtter
  class Twitter

    def initialize(user_name, password, connection)
      @user_name = user_name
      @password = password
      @connection = connection
    end

    def update_status(status)
      @connection.start("twitter.com", @connection.port) do |http|
        uri = '/statuses/update.xml'
        http.request(post_request(uri), "status=#{CGI.escape(status)}&source=#{APP_NAME}")
      end
      status
    end

    def direct_message(user, status)
      @connection.start("twitter.com", @connection.port) do |http|
        uri = '/direct_messages/new.xml'
        http.request(post_request(uri), "user=#{CGI.escape(user)}&text=#{CGI.escape(status)}&source=#{APP_NAME}")
      end
      [user, status]
    end

    def get_user_profile(screen_name)
      uri = "#{@connection.protocol}://twitter.com/users/show/#{screen_name}.json"
      result = JSON.parse(open(uri, :http_basic_authentication => [user_name, password], :proxy => @connection.proxy_uri).read)
      user = User.new
      %w[ name favourites_count url id description protected utc_offset time_zone
          screen_name notifications statuses_count followers_count friends_count
          profile_image_url location following created_at
      ].each do |attr|
        user.__send__("#{attr}=".to_sym, result[attr])
      end
      return user
    end

    def get_friends_timeline(since_id = nil)
      uri =  "#{@connection.protocol}://twitter.com/statuses/friends_timeline.json"
      uri << "?since_id=#{since_id}" if since_id
      return get_timeline(uri)
    end

    def get_user_timeline(screen_name)
      return get_timeline("#{@connection.protocol}://twitter.com/statuses/user_timeline/#{screen_name}.json")
    rescue OpenURI::HTTPError => e
      puts "No such user: #{screen_name}"
      nears = near_users(screen_name)
      puts "near users: #{nears}" unless nears.empty?
      return []
    end

    def search(query)
      results = JSON.parse(open("#{@connection.protocol}://search.twitter.com/search.json?q=" + CGI.escape(query)).read, :proxy => @connection.proxy_uri)['results']
      return results.map do |s|
        status = Status.new
        status.id = s['id']
        status.text = CGI.unescapeHTML(s['text']).gsub(/(\n|\r)/, '').gsub(/#{Regexp.escape(query)}/i, color(color('\0', 41), 37))
        status.created_at = Time.parse(s["created_at"])
        status.user_screen_name = s['from_user']
        status
      end
    end

    def show(id, rth = false)
      get_status = lambda { get_timeline("#{@connection.protocol}://twitter.com/statuses/show/#{id}.json")[0] }
      statuses = []
      statuses << status = Array(Client.public_storage[:log]).detect(get_status) {|s| s.id == id.to_i }
      statuses << show(id, true) if rth && id = status.in_reply_to_status_id
      statuses.flatten
    end

    def replies
      return get_timeline("#{@connection.protocol}://twitter.com/statuses/replies.json")
    end

    def get_timeline(uri)
      data = JSON.parse(open(uri, :http_basic_authentication => [user_name, password], :proxy => @connection.proxy_uri).read)
      data = [data] unless data.instance_of? Array
      return data.map do |s|
        status = Status.new
        status.created_at = Time.parse(s["created_at"])
        %w(id text truncated in_reply_to_status_id in_reply_to_user_id in_reply_to_screen_name).each do |key|
          status.__send__("#{key}=".to_sym, s[key])
        end
        %w(id name screen_name url profile_image_url).each do |key|
          status.__send__("user_#{key}=".to_sym, s["user"][key])
        end
        status.text = CGI.unescapeHTML(status.text).gsub(/(\n|\r)/, '')
        status
      end
    end

    # note: APILimit.reset_time_in_seconds == APILimit.reset_time.to_i
    APILIMIT = Struct.new("APILimit", :reset_time, :reset_time_in_seconds, :remaining_hits, :hourly_limit)
    def get_rate_limit_status
      uri = 'http://twitter.com/account/rate_limit_status.json'
      data = JSON.parse(open(uri, :http_basic_authentication => [user_name, password], :proxy => @connection.proxy_uri).read)

      reset_time = Time.parse(data['reset_time'])
      reset_time_in_seconds = data['reset_time_in_seconds'].to_i
      
      APILIMIT.new(reset_time, reset_time_in_seconds, data['remaining_hits'], data['hourly_limit'])
    end

    alias :api_limit :get_rate_limit_status

    private

    def user_name
      unless @user_name.instance_of? String
        HighLine.track_eof = false
        @user_name = HighLine.new.ask('your twitter username: ')
      end
      @user_name
    end

    def password
      unless @password.instance_of? String
        HighLine.track_eof = false
        @password = HighLine.new.ask('your twitter password: ') { |q| q.echo = false }
      end
      @password
    end

    def near_users(screen_name)
      Client::public_storage[:users].select {|user|
        /#{user}/i =~ screen_name || /#{screen_name}/i =~ user
      }.join(', ')
    end

    def post_request(uri)
      req = Net::HTTP::Post.new(uri)
      req.basic_auth(user_name, password)
      req.add_field('User-Agent', 'Termtter http://github.com/jugyo/termtter')
      req.add_field('X-Twitter-Client', 'Termtter')
      req.add_field('X-Twitter-Client-URL', 'http://github.com/jugyo/termtter')
      req.add_field('X-Twitter-Client-Version', '0.1')
      req
    end
  end
end

