# -*- coding: utf-8 -*-

require 'uri'

module Termtter::Client
  public_storage[:uris] = []

  PROTOCOLS = %w(http https) unless defined? PROTOCOLS

  register_hook(
    :name => :uri_open,
    :points => [:output],
    :exec_proc => lambda {|statuses, event|
      statuses.each do |s|
        public_storage[:uris].unshift *URI.extract(s[:text], PROTOCOLS)
      end
    }
  )

  def self.open_uri(uri)
    cmd =
      unless config.plugins.uri_open.browser.empty?
        config.plugins.uri_open.browser
      else
        case RUBY_PLATFORM
        when /linux/; 'firefox'
        when /mswin(?!ce)|mingw|bccwin/; 'explorer'
        when /cygwin/; 'cygstart -o'
        else; 'open'
        end
      end
    system "#{cmd} #{uri}"
  end

  register_command(
    :name => :'uri-open', :aliases => [:uo],
    :exec_proc => lambda {|arg|
      case arg.strip
      when ''
        open_uri public_storage[:uris].shift
      when /^all$/
        public_storage[:uris].
          each {|uri| open_uri(uri) }.
          clear
      when /^list$/
        public_storage[:uris].
          enum_for(:each_with_index).
          to_a.
          reverse.
          each  do |uri, index|
            puts "#{index}: #{uri}"
          end
      when /^delete\s+(\d+)$/
        puts 'delete'
        public_storage[:uris].delete_at($1.to_i)
      when /^clear$/
        public_storage[:uris].clear
        puts "clear uris"
      when /^in\s+(.*)$/
        $1.split(/\s+/).each do |id|
          if s = Termtter::API.twitter.show(id) rescue nil
            URI.extract(s.text, PROTOCOLS).each do |uri|
              open_uri(uri)
              public_storage[:uris].delete(uri)
            end
          end
        end
      when /^(\d+)$/
        open_uri(public_storage[:uris].delete_at($1.to_i))
      else
        puts "**parse error in uri-open**"
      end
    },
    :completion_proc => lambda {|cmd, arg|
      %w(all list delete clear in).grep(/^#{Regexp.quote arg}/).map {|a| "#{cmd} #{a}" }
    }
  )
end
# ~/.termtter/config
# t.plug 'uri-open'
#
# see also: http://ujihisa.blogspot.com/2009/05/fixed-uri-open-of-termtter.html
#
# KNOWN BUG
# * In Debian, exit or C-c in the termtter would kill your firefox.
