# -*- coding: utf-8 -*-

module Termtter::Client
  public_storage[:uris] = []

  register_hook(
    :name => :uri_open,
    :points => [:output],
    :exec_proc => lambda {|statuses, event|
      statuses.each do |s|
        public_storage[:uris] = s[:text].scan(%r|https?://[^\s]+|) + public_storage[:uris]
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
        else; 'open'
        end
      end
    if ENV['TERM'] == 'screen' || cmd =~ /.*w3m/
      system "screen", "-X", "eval", "split", "focus", "screen #{cmd} #{uri}"
    else 
      system cmd, uri
    end
  end

  register_command(
    :name => :'uri-open', :aliases => [:uo],
    :exec_proc => lambda {|arg|
      case arg
      when ''
        open_uri public_storage[:uris].shift
      when /^\s*all\s*$/
        public_storage[:uris].
          each {|uri| open_uri(uri) }.
          clear
      when /^\s*list\s*$/
        public_storage[:uris].
          enum_for(:each_with_index).
          to_a.
          reverse.
          each  do |uri, index|
            puts "#{index}: #{uri}"
          end
      when /^\s*delete\s+(\d+)\s*$/
        puts 'delete'
        public_storage[:uris].delete_at($1.to_i)
      when /^\s*clear\s*$/
        public_storage[:uris].clear
        puts "clear uris"
      when /^\s*(\d+)\s*$/
        open_uri(public_storage[:uris].delete_at($1.to_i))
      else
        puts "**parse error in uri-open**"
      end
    },
    :completion_proc => lambda {|cmd, arg|
      %w(all list delete clear).grep(/^#{Regexp.quote arg}/).map {|a| "#{cmd} #{a}" }
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
