#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

$KCODE = 'u'

self_file =
  if File.ftype(__FILE__) == 'link'
    File.readlink(__FILE__)
  else
    __FILE__
  end
$:.unshift(File.dirname(self_file) + "/lib")

require 'termtter'
Termtter::Client.run

# Startup scripts for development
