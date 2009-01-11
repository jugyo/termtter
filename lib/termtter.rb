$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'json'
require 'net/https'
require 'open-uri'
require 'cgi'
require 'readline'
require 'enumerator'
require 'parsedate'
require 'configatron'

configatron.set_default(:update_interval, 300)
configatron.set_default(:prompt, '> ')
configatron.set_default(:enable_ssl, false)
configatron.proxy.set_default(:port, '8080')

require 'termtter/twitter'
require 'termtter/connection'
require 'termtter/client'
require 'termtter/status'

module Termtter
  VERSION = '0.7.6'
  APP_NAME = 'termtter'
  CONF_FILE = '~/.termtterrc' # still does not use
  CONF_DIR = '~/.termtter' # still does not use
end

if RUBY_VERSION < '1.8.7'
  class Array
    def take(n) self[0...n] end
  end
end

def win?
  RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|bccwin/
end

if win?
  require 'kconv'
  module Readline
    alias :old_readline :readline
    def readline(*a)
      old_readline(*a).toutf8
    end
    module_function :old_readline, :readline
  end
end

def plugin(s)
  require "plugin/#{s}"
end

def filter(s)
  load "filter/#{s}.rb"
rescue LoadError
  raise
else
  Termtter::Client.public_storage[:filters] ||= []
  Termtter::Client.public_storage[:filters] << s
  true
end

$:.unshift(Termtter::CONF_DIR) # still does not use

