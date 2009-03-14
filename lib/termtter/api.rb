# -*- coding: utf-8 -*-
require 'rubytter'

configatron.set_default(:host, 'twitter.com')
configatron.proxy.set_default(:port, '8080')
configatron.proxy.set_default(:host, nil)
configatron.proxy.set_default(:port, nil)
configatron.proxy.set_default(:user_name, nil)
configatron.proxy.set_default(:password, nil)
configatron.set_default(:enable_ssl, false)

module Termtter
  module API
    class << self
      attr_reader :connection, :twitter, :twitter_old
      def setup
        @connection = Connection.new
        @twitter = Rubytter.new(
                    configatron.user_name,
                    configatron.password,
                    {
                      :host => configatron.host,
                      :header => {
                        'User-Agent' => 'Termtter http://github.com/jugyo/termtter',
                        'X-Twitter-Client' => 'Termtter',
                        'X-Twitter-Client-URL' => 'http://github.com/jugyo/termtter',
                        'X-Twitter-Client-Version' => '0.1'
                      },
                      :enable_ssl => configatron.enable_ssl,
                      :proxy_host => configatron.proxy.host,
                      :proxy_port => configatron.proxy.port,
                      :proxy_user_name => configatron.proxy.user_name,
                      :proxy_password => configatron.proxy.password
                    }
                  )
        @twitter_old = Termtter::Twitter.new(configatron.user_name, configatron.password, @connection)
      end
    end
  end
end
# Termtter::API.connection, Termtter::API.twitter can be accessed.
