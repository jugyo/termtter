# -*- coding: utf-8 -*-

$:.unshift(File.dirname(__FILE__) + '/../lib')
ARGV.delete '-c'
require 'termtter'

def be_quiet
  dummy = StringIO.new
  $stderr, orig = dummy, $stderr
  yield
  $stderr = orig
  dummy.rewind
  dummy.read
end

