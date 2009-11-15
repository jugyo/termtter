# coding: utf-8

require 'haml'
require 'tempfile'

module Termtter::Plugins
  class Haml
    def initialize(config = Termtter::Config.instance, logger = Termtter::Client.logger)
      @config, @logger = config, logger

      plugin_config.set_default :options, {}
    end

    def plugin_config
      @config.plugins.haml
    end

    def run(arg)
      hamlified = haml(arg)

      return if hamlified.nil? || hamlified.empty?

      Termtter::API.twitter.update(hamlified)
      puts "=> #{hamlified}"
    rescue Exception => e
      @logger.error e
    end

    def haml(format)
      return unless input = editor(:haml)

      opts = plugin_config.options.merge(format.empty? ? {} : {:format => format.to_sym})
      ::Haml::Engine.new(editor(:haml), opts).render(Termtter::Client).chomp
    end

    def editor(extname)
      unless cmd = ENV['VISUAL'] || ENV['EDITOR']
        raise 'Please set VISUAL or EDITOR variable.'
      end

      # XXX: works only in Ruby 1.8.7 or later
      Tempfile.open(['tmp', ".#{extname}"]) do |f|
        system cmd, f.path
        return f.read
      end
    end
  end
end

Termtter::Client.register_command(:haml) do |arg|
  Termtter::Plugins::Haml.new.run(arg)
end
