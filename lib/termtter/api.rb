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
        # NOTE: for compatible
        @connection = twitter.instance_variable_get(:@connection)
        if config.access_token.empty? || config.access_token_secret.empty?
          puts "<red>Error!!</red>: You must setup conig for OAuth. Rerun termtter after removing '#{CONF_FILE}'.".termcolor
          exit!
        else
          consumer = OAuth::Consumer.new(CONSUMER_KEY, CONSUMER_SECRET, :site => 'http://twitter.com')
          access_token = OAuth::AccessToken.new(consumer, config.access_token, config.access_token_secret)
          @twitter = RubytterProxy.new(access_token, twitter_option)
        end

        config.user_name = @twitter.verify_credentials[:screen_name]
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
