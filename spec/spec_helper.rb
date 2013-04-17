# -*- coding: utf-8 -*-

$:.unshift(File.dirname(__FILE__) + '/../lib')
ARGV.delete '-c'
require 'termtter'

if ENV['COVERAGE'] == 'on'
  require 'simplecov'
  require 'simplecov-rcov'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter

  SimpleCov.start do
    add_filter "spec"
    add_filter "vendor"
  end
end

def be_quiet(options = {})
  out = (v = options.delete(:stdout)).nil? ? true : v
  err = (v = options.delete(:stderr)).nil? ? true : v
  if out
    out_dummy = StringIO.new
    $stdout, out_orig = out_dummy, $stdout
  end
  if err
    err_dummy = StringIO.new
    $stderr, err_orig = err_dummy, $stderr
  end
  yield
  result = {}
  if out
    $stdout = out_orig
    out_dummy.rewind
    result[:stdout] = out_dummy.read
  end
  if err
    $stderr = err_orig
    err_dummy.rewind
    result[:stderr] = err_dummy.read
  end
  result
end
