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
gem 'rubytter', '>= 0.11.0'
require 'rubytter'
require 'notify'
require 'timeout'

module Termtter
  VERSION = File.read(File.join(File.dirname(__FILE__), '../VERSION')).strip
  APP_NAME = 'termtter'

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
  $:.unshift(CONF_DIR)

  CONSUMER_KEY = Termtter::Crypt.decrypt("WXxHe09FeWlRRkd1S0ZlM05FQ3pPRlN1S0ZtNk5FQ3pPVm11S0ZXek5FQzRR\nVXlpUHxbdUtGR3lPRXlpDFB8W3VLRkd6T1V5aVBWU3VLRkd5UHt5aU9WQ3pO\nRUMzT2t5aU9WRzJORUM1UGt5aVFGW3VLRkd6UVV5aQxPVkM2TkVDNFBYMj8M")
  CONSUMER_SECRET = Termtter::Crypt.decrypt("WXxHek97eWlPVkd6TkVDMlFVeWlPVkM3TkVDek9WR3VLRmV8TkVDNVFVeWlP\nVkc3TkVDek9WU3VLRmU3DE5FQzRQe3lpUHxHdUtGZTZORUN6T0ZHdUtGbXlO\nRUMyUVV5aU9WQzVORUM1T0V5aU9WQzZORUN6T2xLdQxLRm03TkVDNVBFeWlQ\nfGV1S0ZHeVFVeWlQVld1S0ZlfE5FQzZPVXlpT1ZLek5FQzNQe3lpUHxPdUtG\nbTUMTkVDM1B7eWlPVkc0TkVDM1BVeWlQfFd1S0ZHeVB7eWlPVkd8TkVDek9W\nR3VLRls3TkVDek9WaXVLRmV7DE5FQ3pPRmZmDA==")
end
