#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

self_file =
  if File.symlink?(__FILE__)
    require 'pathname'
    Pathname.new(__FILE__).realpath
  else
    __FILE__
  end
$:.unshift(File.dirname(self_file) + "/lib")

if ARGV.delete('--upgrade')
  Dir.chdir(File.dirname(self_file)) do
    system "git pull --rebase" or abort "git-pull failed"
  end
end

require 'termtter'
Termtter::OptParser.parse!(ARGV)
Termtter::Client.run

# Startup scripts for development
