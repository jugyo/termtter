# -*- coding: utf-8 -*-
gem 'rubytter', '>= 0.6.5'
require 'rubytter'

config.set_default(:host, 'twitter.com')
config.proxy.set_default(:port, '8080')
config.proxy.set_default(:host, nil)
config.proxy.set_default(:port, nil)
config.proxy.set_default(:user_name, nil)
config.proxy.set_default(:password, nil)
config.set_default(:enable_ssl, false)

module Termtter
  module API
    class << self
      attr_reader :twitter
      def setup
        @twitter = create_twitter(config.user_name, config.password)
      end

      alias restore_user setup

      def switch_user(username = nil, password = nil)
        highline = create_highline
        username = highline.ask('your twitter username: ') if username.nil? || username.empty?
        password = highline.ask('your twitter password: ') { |q| q.echo = false } if username.nil? || username.empty?
        @twitter = create_twitter(username, password)
      end

      def create_twitter(user_name, password)
        Rubytter.new(
          user_name,
          password,
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
        )
      end
    end
  end
end
# Termtter::API.twitter can be accessed.
