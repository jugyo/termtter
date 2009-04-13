# -*- coding: utf-8 -*-

require 'uri'

module Termtter::Client
  def self.open_uri(uri)
    unless config.plugins.open_url.browser.empty?
      system config.plugins.open_url.browser, uri
    else
      case RUBY_PLATFORM
      when /linux/
        system 'firefox', uri
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
        if public_storage[:typable_id] && status = typable_id_status(arg)
          status.text.gsub(URI.regexp) {|uri|
            open_uri(uri)
          }
        else
          case arg
          when /^@([A-Za-z0-9_]+)/
            user = $1
            statuses = Termtter::API.twitter.user_timeline(user)
            return if statuses.empty?
            statuses[0].text.gsub(URI.regexp) {|uri| open_uri(uri) }
          when /^\d+/
            Termtter::API.twitter.show(arg).text.gsub(URI.regexp) {|uri| open_uri(uri) }
          end
        end
      end
    },
    :completion_proc => lambda {|cmd, arg|
      if public_storage[:typable_id] && typable_id?(arg)
        "#{cmd} #{typable_id_convert(arg)}"
      else
        case arg
        when /@(.*)/
          find_user_candidates $1, "#{cmd} @%s"
        when /(\d+)/
          find_status_ids(arg).map{|id| "#{cmd} #{$1}"}
        end
      end
    }
  )
end

#Optional Setting
#  config.plugins.open_url.browser = firefox
