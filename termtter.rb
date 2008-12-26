#!/usr/bin/env ruby

$KCODE = 'u'

require 'yaml'
require 'lib/termtter'

# Hooks
require 'termtter/stdout'
#require 'termtter/notify-send'

Termtter::Client.new(YAML.load(open('config.yml'))).run

