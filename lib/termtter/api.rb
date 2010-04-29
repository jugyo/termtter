# -*- coding: utf-8 -*-

config.set_default(:host, 'twitter.com')
if ENV.has_key?('HTTP_PROXY')
  require 'uri'
  proxy = ENV['HTTP_PROXY']
  proxy = "http://" + proxy if proxy !~ /^http:\/\//
  u = URI.parse(proxy)
  config.proxy.set_default(:host, u.host)
  config.proxy.set_default(:port, u.port.to_s)

  if u.userinfo.nil?
    config.proxy.set_default(:host, nil)
    config.proxy.set_default(:port, nil)
  else
    user_name,password = u.userinfo.split(/:/)
    config.proxy.set_default(:user_name, user_name)
    config.proxy.set_default(:password, password)
  end
else
  config.proxy.set_default(:host, nil)
  config.proxy.set_default(:port, nil)
end
config.proxy.set_default(:user_name, nil)
config.proxy.set_default(:password, nil)
config.set_default(:enable_ssl, false)

module Termtter
  module API
    class << self
      attr_reader :connection, :twitter
      def setup
        3.times do
          begin
            if twitter = try_auth
              @twitter = twitter
              # NOTE: for compatible
              @connection = twitter.instance_variable_get(:@connection)
              break
            end
          rescue Timeout::Error
            puts TermColor.parse("<red>Time out :(</red>")
            exit!
          end
        end

        exit! unless twitter
      end

      def try_auth
        if config.user_name.empty? || config.password.empty?
          puts 'Please enter your Twitter login:'
        end

        ui = create_highline

        if config.user_name.empty?
          config.user_name = ui.ask('Username: ')
        else
          puts "Username: #{config.user_name}"
        end
        if config.password.empty?
          config.password = ui.ask('Password: ') { |q| q.echo = false}
        end

        # TODO: Change this to jugyo's key
        if File.exist?(File.expand_path("~/.termtter/access_token"))
          access_token = File.read(File.expand_path("~/.termtter/access_token")).chomp
        else
          access_token = Rubytter::OAuth.new(
            Termtter::Crypt.decrypt(
              "WXxHelB7eWlPVkc1TkVDek9GW3VLRml7TkVDNFBreWlPVkM3TkVDM1B7eWlQ\nbG11S0ZXeU5FQzZQe3lpDFFWbXVLRml6TkVDM097eWlQfGl1S0ZXek5FQzNQ\nVXlpUFZLdUtGaXpORUN6T0ZHdUtGZXxORUN6T1ZuZgw="),
            Termtter::Crypt.decrypt(
              "WXxHeU9reWlQfG11S0ZHeU9reWlPVkd6TkVDek9GV3VLRmV6TkVDek9WaXVL\nRml5TkVDek9GS3VLRm15DE5FQzVPRXlpUHxPdUtGaTdORUN6T1ZXdUtGbTdO\nRUM3UUV5aVBWU3VLRm01TkVDNU9FeWlPVkd6TkVDNAxRVXlpUVZpdUtGV3tO\nRUN6T1ZldUtGR3lPa3lpT1ZHN05FQ3pPVmV1S0ZpN05FQ3pPVlN1S0ZXMk5F\nQzUMUGt5aVB8ZXVLRmUzTkVDek9GR3VLRmUyTkVDek9GT3VLRml6TkVDek9W\nT3VLRkd5T0V5aU9WR3lORUN6DE9WaXVLRm03WlM/Pww=")) \
            .get_access_token_with_xauth(config.user_name, config.password)
          open("~/.termtter/access_token","w"){|f| f.puts access_token }
        end
        twitter = RubytterProxy.new(access_token, twitter_option)
        begin
          twitter.verify_credentials
          return twitter
        rescue Rubytter::APIError
          config.__clear__(:password)
        end
        return nil
      end

      def twitter_option
        {
          :app_name => config.app_name.empty? ? Termtter::APP_NAME : config.app_name,
          :host => config.host,
          :header => {
            'User-Agent' => 'Termtter http://github.com/jugyo/termtter',
            'X-Twitter-Client' => 'Termtter',
            'X-Twitter-Client-URL' => 'http://github.com/jugyo/termtter',
            'X-Twitter-Client-Version' => Termtter::VERSION
          },
          :enable_ssl => config.enable_ssl,
          :proxy_host => config.proxy.host,
          :proxy_port => config.proxy.port,
          :proxy_user_name => config.proxy.user_name,
          :proxy_password => config.proxy.password
        }
      end
    end
  end
end
# Termtter::API.connection, Termtter::API.twitter can be accessed.
