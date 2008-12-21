#!/usr/bin/env ruby

$KCODE = 'u'

require 'yaml'
require 'termtter/termtter'

# Hooks
require 'termtter/stdout'
#require 'termtter/notify-send'

Termtter.new(YAML.load(open('config.yml'))).run

