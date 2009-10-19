# -*- coding: utf-8 -*-

require 'erb'

module Termtter
  module ConfigSetup
    module_function
    def run
      puts 'connecting to twitter...'

      consumer = OAuth::Consumer.new(CONSUMER_KEY, CONSUMER_SECRET, :site => 'http://twitter.com')
      request_token = consumer.get_request_token

      unless open_brawser(request_token.authorize_url)
        puts "Authorize URL: #{request_token.authorize_url}"
      end
      sleep 2

      ui = create_highline
      pin = ui.ask('Please enter PIN: ')
      access_token = request_token.get_access_token(:oauth_verifier => pin)
      token = access_token.token
      secret = access_token.secret

      plugins = Dir.glob(File.expand_path(File.dirname(__FILE__) + "/../plugins/*.rb")).map  {|f|
        f.match(%r|lib/plugins/(.*?).rb$|)[1]
      }
      standard_plugins = %w[stdout standard_commands auto_reload]

      template = open(File.dirname(__FILE__) + '/config_template.erb').read
      config = ERB.new(template, nil, '-').result(binding) # trim_mode => '-'

      Dir.mkdir(Termtter::CONF_DIR) unless File.exists?(Termtter::CONF_DIR)
      File.open(Termtter::CONF_FILE, 'w', 0600) {|io|
        io << config
      }

      puts "generated: ~/.termtter/config"
      puts "enjoy!"
    rescue OAuth::Unauthorized
      puts 'failed to authentication!'
      exit 1
    end
  end
end
