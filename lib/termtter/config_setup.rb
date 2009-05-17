# -*- coding: utf-8 -*-

require 'erb'

module Termtter
  module ConfigSetup
    module_function
    def run
      ui = create_highline
      user_name = ui.ask('your twitter user name: ')
      password = ui.ask('your twitter password: ') { |q| q.echo = false }

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
    end
  end
end
