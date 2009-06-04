#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

self_file =
  if File.ftype(__FILE__) == 'link'
    File.readlink(__FILE__)
  else
    __FILE__
  end
$:.unshift(File.dirname(self_file) + "/lib")

require 'termtter'
# config.devel = true unless ARGV.include? 'normal'
Termtter::Client.run

# Startup scripts for development
