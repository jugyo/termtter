#!/usr/bin/env ruby

$KCODE = 'u'

require 'yaml'
require 'lib/termtter'

# Hooks
require 'lib/stdout'
#require 'lib/notify-send'

Termtter.new(YAML.load(open('config.yml'))).run

