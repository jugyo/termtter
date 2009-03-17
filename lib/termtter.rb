# -*- coding: utf-8 -*-

$KCODE="u" unless Object.const_defined? :Encoding

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'json'
require 'net/https'
require 'open-uri'
require 'cgi'
require 'readline'
require 'enumerator'
require 'optparse'

require 'termtter/config'
require 'termtter/version'
require 'termtter/optparse'
require 'termtter/connection'
require 'termtter/command'
require 'termtter/hook'
require 'termtter/task'
require 'termtter/task_manager'
require 'termtter/client'
require 'termtter/api'
require 'termtter/system_extensions'
