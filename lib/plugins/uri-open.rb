# -*- coding: utf-8 -*-

module Termtter::Client
  public_storage[:uris] = []

  add_hook do |statuses, event, t|
    if !statuses.empty? && event == :update_friends_timeline
      statuses.each do |s|
        public_storage[:uris] += s.text.scan(%r|https?://[^\s]+|)
      end
    end
  end

  def self.open_uri(uri)
    unless config.plugins.uri_open.browser.empty?
      system config.plugins.uri_open.browser, uri
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
    :name => :'uri-open', :aliases => [:uo],
    :exec_proc => lambda{|arg|
      case arg
      when /^\s+$/
        public_storage[:uris].each do |uri|
          open_uri(uri)
        end
        public_storage[:uris].clear
      when /^\s*list\s*$/
        public_storage[:uris].each_with_index do |uri, index|
          puts "#{index}: #{uri}"
        end
      when /^\s*delete\s+(\d+)\s*$/
        puts 'delete'
        public_storage[:uris].delete_at($1.to_i)
      when /^\s*clear\s*$/
        public_storage[:uris].clear
        puts "clear uris"
      when /^\s*(\d+)\s*$/
        open_uri(public_storage[:uris][$1.to_i])
        public_storage[:uris].delete_at($1.to_i)
      end
    },
    :completion_proc => lambda{|cmd, arg|
      %w(list delete clear).grep(/^#{Regexp.quote arg}/).map{|a| "#{cmd} #{a}"}
    }
  )
end
# ~/.termtter
# plugin 'uri-open'
#
# see also: http://ujihisa.nowa.jp/entry/c3dd00c4e0
#
# KNOWN BUG
# * In Debian, exit or C-c in the termtter kills your firefox.
