# -*- coding: utf-8 -*-

require 'erb'

module Termtter
  module ConfigSetup
    module_function

    def run

      plugins = Dir.glob(File.expand_path(File.dirname(__FILE__) + "/../plugins/*.rb")).map  {|f|
        f.match(%r|lib/plugins/(.*?).rb$|)[1]
      }
      standard_plugins = %w[stdout standard_commands auto_reload defaults]

      template = open(File.dirname(__FILE__) + '/config_template.erb').read
      config = ERB.new(template, nil, '-').result(binding) # trim_mode => '-'

      Dir.mkdir(Termtter::CONF_DIR) unless File.exists?(Termtter::CONF_DIR)
      File.open(Termtter::CONF_FILE, 'w', 0600) {|io|
        io << config
      }

      puts "generated: ~/.termtter/config"

      token_and_secret = Termtter::API.authorize_by_oauth
      token = token_and_secret[:token]
      secret = token_and_secret[:secret]

      puts "Setup is completed. Enjoy!"
    rescue OAuth::Unauthorized
      puts 'Failed to authenticate!'
      exit!
    end
  end
end
