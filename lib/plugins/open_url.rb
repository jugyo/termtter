# -*- coding: utf-8 -*-

require 'uri'

module Termtter::Client
  def self.open_uri(uri)
    unless config.plugins.open_url.browser.empty?
      system config.plugins.open_url.browser, uri
    else
      case RUBY_PLATFORM
      when /linux/
        system 'xdg-open', uri
      when /mswin(?!ce)|mingw|bccwin/
        system 'explorer', uri
      else
        system 'open', uri
      end
    end
  end

  register_command(
    :name      => :open_url,
    :help      => ['open_url (TYPABLE|ID|@USER)', 'Open url'],
    :exec_proc => lambda {|arg|
      Thread.new(arg) do |arg|
        if status = Termtter::Client.typable_id_to_data(arg)
          status.text.gsub(URI.regexp(['http', 'https'])) {|uri|
            open_uri(uri)
          }
        else
          case arg
          when /^@([A-Za-z0-9_]+)/
            user = $1
            statuses = Termtter::API.twitter.user_timeline(:screen_name => user)
            return if statuses.empty?
            statuses[0].text.gsub(URI.regexp(['http', 'https'])) {|uri| open_uri(uri) }
          when /^\d+/
            Termtter::API.twitter.show(arg).text.gsub(URI.regexp(['http', 'https'])) {|uri| open_uri(uri) }
          end
        end
      end
    }
  )
end

#Optional Setting
#  config.plugins.open_url.browser = 'firefox'
