# -*- coding: utf-8 -*-
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
      attr_reader :connection, :twitter, :twitter_old
      def setup
        @connection = Connection.new
        @twitter = Rubytter.new(
                    config.user_name,
                    config.password,
                    {
                      :app_name => Termtter::APP_NAME,
                      :host => config.host,
                      :header => {
                        'User-Agent' => 'Termtter http://github.com/jugyo/termtter',
                        'X-Twitter-Client' => 'Termtter',
                        'X-Twitter-Client-URL' => 'http://github.com/jugyo/termtter',
                        'X-Twitter-Client-Version' => '0.1'
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
# Termtter::API.connection, Termtter::API.twitter can be accessed.
