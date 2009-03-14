# -*- coding: utf-8 -*-

require 'highline'
require 'termcolor'
require 'time'

module Termtter
  class Twitter

    def initialize(user_name, password, connection, host = "twitter.com")
      @user_name = user_name
      @password = password
      @connection = connection
      @host = host
    end

    def update_status(status)
      @connection.start(@host, @connection.port) do |http|
        uri = '/statuses/update.xml'
        http.request(post_request(uri), "status=#{CGI.escape(status)}&source=#{APP_NAME}")
      end
      status
    end

    def direct_message(user, status)
      @connection.start(@host, @connection.port) do |http|
        uri = '/direct_messages/new.xml'
        http.request(post_request(uri), "user=#{CGI.escape(user)}&text=#{CGI.escape(status)}&source=#{APP_NAME}")
      end
      [user, status]
    end

    def get_user_profile(screen_name)
      result = fetch_as_json(url_for("/users/show/#{screen_name}.json"))
      return hash_to_user(result)
    end

    def get_friends_timeline(since_id = nil)
      uri =  url_for("/statuses/friends_timeline.json")
      uri << "?since_id=#{since_id}" if since_id
      return get_timeline(uri)
    end

    def user_timeline(screen_name)
      return get_timeline(url_for("/statuses/user_timeline/#{screen_name}.json"))
    rescue OpenURI::HTTPError => e
      case e.message
      when /404/
        warn "No such user: #{screen_name}"
        nears = near_users(screen_name)
        puts "near users: #{nears}" unless nears.empty?
        return []
      end
      raise
    end

    config.search.set_default(:highlihgt_text_format, '<on_magenta><white>\1</white></on_magenta>')
    def search(query)
      results = fetch_as_json(search_url_for("/search.json?q=#{CGI.escape(query)}"))['results']
      return results.map do |s|
        status = Status.new
        status.id = s['id']
        status.text = s['text'].
                        gsub(/(\n|\r)/, '').
                        gsub(/(#{Regexp.escape(query)})/i, config.search.highlihgt_text_format)
        status.created_at = Time.parse(s["created_at"])
        status.user.screen_name = s['from_user']
        status
      end
    end

    def show(id, rth = false)
      get_status = lambda { get_timeline(url_for("/statuses/show/#{id}.json"))[0] }
      statuses = []
      statuses << status = Array(Client.public_storage[:log]).detect(get_status) {|s| s.id == id.to_i }
      statuses << show(id, true) if rth && status && id = status.in_reply_to_status_id
      statuses.flatten.compact
    end

    def replies
      return get_timeline(url_for("/statuses/replies.json"))
    end

    def followers
      users = []
      page = 0
      begin
        users += tmp = fetch_as_json(url_for("/statuses/followers.json?page=#{page+=1}"))
      end until tmp.empty?
      return users.map{|u| hash_to_user(u)}
    end

    def get_timeline(uri)
      data = fetch_as_json(uri)
      data = [data] unless data.instance_of? Array
      return data.map do |s|
        status = Status.new
        status.created_at = Time.parse(s["created_at"])
        %w(id text truncated in_reply_to_status_id in_reply_to_user.id in_reply_to_screen_name).each do |key|
          status.__send__("#{key}=".to_sym, s[key])
        end
        %w(id name screen_name url profile_image_url).each do |key|
          status.__send__("user_#{key}=".to_sym, s["user"][key])
        end
        status.text = status.text.gsub(/(\n|\r)/, '')
        status
      end
    end

    # note: APILimit.reset_time_in_seconds == APILimit.reset_time.to_i
    APILIMIT = Struct.new("APILimit", :reset_time, :reset_time_in_seconds, :remaining_hits, :hourly_limit)
    def get_rate_limit_status
      data = fetch_as_json(url_for("/account/rate_limit_status.json"))
      reset_time = Time.parse(data['reset_time'])
      reset_time_in_seconds = data['reset_time_in_seconds'].to_i
      
      APILIMIT.new(reset_time, reset_time_in_seconds, data['remaining_hits'], data['hourly_limit'])
    end

    alias :api_limit :get_rate_limit_status

    private

    def hash_to_user(hash)
      user = User.new
      %w[ name favourites_count url id description protected utc_offset time_zone
          screen_name notifications statuses_count followers_count friends_count
          profile_image_url location following created_at
      ].each do |attr|
        user.__send__("#{attr}=".to_sym, hash[attr])
      end
      return user
    end

    def fetch_as_json(uri)
      JSON.parse(open_uri(uri).read)
    rescue OpenURI::HTTPError => e
      case e.message
      when /403/, /401/
        warn '[PROTECTED USER] You must add to show his/her tweet.'
        return []
      when /500/
        warn 'Twitter Birds say: Something wrong!'
        return []
      end
      raise
    end

    def open_uri(uri)
      return open(uri, :http_basic_authentication => [user_name, password], :proxy => @connection.proxy_uri)
    end

    def url_for(path)
      return "#{@connection.protocol}://#{@host}/#{path.sub(/^\//, '')}"
    end

    def search_url_for(path)
      return "#{@connection.protocol}://search.#{@host}/#{path.sub(/^\//, '')}"
    end

    def user_name
      unless @user_name.instance_of? String
        Termtter::Client.create_highline.ask('your twitter username: ')
      end
      @user_name
    end

    def password
      unless @password.instance_of? String
        @password = Termtter::Client.create_highline.ask('your twitter password: ') { |q| q.echo = false }
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
