# -*- coding: utf-8 -*-

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
      attr_reader :connection, :twitter
      def setup
        @connection = Connection.new

        auth = false
        3.times do
          if twitter = try_auth
            @twitter = twitter
            auth = true
            break
          end
        end

        exit! unless auth
      end

      def try_auth
        if config.user_name.empty? || config.password.empty?
          puts 'Please enter your Twitter login:'
        end

        ui = create_highline

        if config.user_name.empty?
          config.user_name = ui.ask('Username: ')
        end
        if config.password.empty?
          config.password = ui.ask('Password: ') { |q| q.echo = false}
        end

        twitter = Rubytter.new(config.user_name, config.password, twitter_option)
        begin
          twitter.verify_credentials
          return twitter
        rescue Rubytter::APIError
          config.__clear__(:user_name)
          config.__clear__(:password)
        end
        return nil
      end

      def restore_user
	setup
      end

      def switch_user(username = nil)
        highline = create_highline
        config.user_name = highline.ask('your twitter username: ') if username.nil? || username.empty?
        config.password = highline.ask('your twitter password: ') { |q| q.echo = false }
	setup
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
