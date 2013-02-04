# -*- mode: ruby; coding: utf-8 -*-
require 'rubygems'
require 'bundler'
require 'rake'
require 'rake/clean'
require 'rubygems/package_task'
require 'rdoc/task'
require 'rspec/core'
require 'rspec/core/rake_task'

Bundler::GemHelper.install_tasks

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.rspec_opts = ["-c","-fs"]
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :default => :spec

desc 'Generate documentation for the termtter.'
RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Termtter"
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
