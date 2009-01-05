#!/usr/bin/env ruby

$KCODE = 'u'

self_file =
  if File.ftype(__FILE__) == 'link'
    File.readlink(__FILE__)
  else
    __FILE__
  end
$:.unshift(File.dirname(self_file) + "/lib")

require 'termtter'
require 'plugin/standard_commands'
require 'plugin/stdout'

configatron.update_interval

conf_file = File.expand_path('~/.termtter')
if File.exist? conf_file
  load conf_file
else
  puts '~/.termtter not found.'
  exit 1
end

Termtter::Client.run

# Startup scripts for development
