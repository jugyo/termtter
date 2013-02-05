# -*- coding: utf-8 -*-

$KCODE = "u" unless Object.const_defined? :Encoding

$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) ||
                                          $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'

require 'cgi'
require 'enumerator'
require 'json'
require 'net/https'
require 'open-uri'
require 'optparse'
require 'readline'
require 'rubytter'
require 'notify'
require 'timeout'
require 'oauth'

module Termtter
  APP_NAME = 'termtter'

  require 'termtter/version'
  require 'termtter/config'
  require 'termtter/crypt'
  require 'termtter/default_config'
  require 'termtter/optparse'
  require 'termtter/command'
  require 'termtter/hook'
  require 'termtter/task'
  require 'termtter/task_manager'
  require 'termtter/hookable'
  require 'termtter/memory_cache'
  require 'termtter/rubytter_proxy'
  require 'termtter/client'
  require 'termtter/api'
  require 'termtter/system_extensions'
  require 'termtter/httppool'
  require 'termtter/event'

  OptParser.parse!(ARGV)
  CONF_DIR = File.expand_path('~/.termtter') unless defined? CONF_DIR
  CONF_FILE = File.join(Termtter::CONF_DIR, 'config') unless defined? CONF_FILE
  config.token_file = File.join(Termtter::CONF_DIR, config.token_file_name)
  USER_LIB = File.join(Termtter::CONF_DIR, 'lib')
  $:.unshift(USER_LIB) if File.exist?(USER_LIB)
  $:.unshift(CONF_DIR)

  CONSUMER_KEY = 'eFFLaGJ3M0VMZExvNmtlNHJMVndsQQ=='
  CONSUMER_SECRET = 'cW8xbW9JT3dyT0NHTmVaMWtGbHpjSk1tN0lReTlJYTl0N0trcW9Fdkhr'
end
