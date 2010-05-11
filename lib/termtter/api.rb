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
          if config.token_file &&
               File.exist?(File.expand_path(config.token_file))
            config.access_token, config.access_token_secret = File.read(File.expand_path(config.token_file)) \
                                                                  .split(/\r?\n/).map(&:chomp)
          else
            self.authorize_by_oauth(true)
          end
        end

        consumer = OAuth::Consumer.new(
          Termtter::Crypt.decrypt(CONSUMER_KEY),
          Termtter::Crypt.decrypt(CONSUMER_SECRET),
          :site => 'http://twitter.com'
        )
        access_token = OAuth::AccessToken.new(consumer, config.access_token, config.access_token_secret)
        @twitter = RubytterProxy.new(access_token, twitter_option)

        config.user_name = @twitter.verify_credentials[:screen_name]
      end
      
      def authorize_by_oauth(show_information=false, save_to_token_file=true, verbose=true)
        if show_information
          puts '                              <on_blue>INFORMATION</on_blue>'.termcolor
          puts <<-EOI
  Twitter called "We'll shutdown BASIC authorize method".
  So authorize method of termtter is switchover from BASIC to OAuth.
  This wizard gets OAuth access token and secret.

          EOI
        end
        puts '1. Contacting to twitter...' if verbose

        consumer = OAuth::Consumer.new(
          Termtter::Crypt.decrypt(CONSUMER_KEY),
          Termtter::Crypt.decrypt(CONSUMER_SECRET),
          :site => 'http://twitter.com',
          :proxy => ENV['http_proxy']
        )
        request_token = consumer.get_request_token

        puts '2. URL for authorize: ' + request_token.authorize_url if verbose
        puts '   Opening web page to authorization...' if verbose

        open_browser(request_token.authorize_url)
        sleep 2

        ui = create_highline
        pin = ui.ask('3. Enter PIN: ')
        puts "4. Getting access_token..."
        access_token = request_token.get_access_token(:oauth_verifier => pin)

        config.access_token = access_token.token
        config.access_token_secret = access_token.secret

        if save_to_token_file
          puts "5. Saving to token file... (" + config.token_file + ")"
          open(File.expand_path(config.token_file),"w") do |f|
            f.puts config.access_token
            f.puts config.access_token_secret
          end
        end

        puts "Authorize is successfully done."

        return {:token  => access_token.token,
                :secret => access_token.secret}
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
