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
  spec.rspec_opts = ["-c", "-fs"]
  spec.pattern = FileList['spec/**/*_spec.rb']
end

namespace :spec do
  desc "Run RSpec for plugins"
  RSpec::Core::RakeTask.new(:plugins) do |spec|
    spec.rspec_opts = ["-c", "-fs"]
    spec.pattern = FileList['spec/plugins/**/*_spec.rb']
  end

  desc "Run RSpec for main procedure"
  RSpec::Core::RakeTask.new(:termtter) do |spec|
    spec.rspec_opts = ["-c", "-fs"]
    spec.pattern = FileList['spec/termtter/**/*_spec.rb']
  end
end

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "termtter"
  gem.homepage = "http://termtter.github.com/"
  gem.license = "MIT"
  gem.summary = %Q{Terminal based Twitter client.}
  gem.description = %Q{Termtter is a terminal based Twitter client.}
  gem.rubyforge_project = %Q{termtter}
  gem.email = "jugyo.org@gmail.com"
  gem.authors = ["jugyo", "ujihisa", "koichiroo", "id774"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

if RUBY_VERSION >= '1.9.0'
  desc "Run RSpec code examples with simplecov"
  task :simplecov do
    ENV['COVERAGE'] = "on"
    Rake::Task[:spec].invoke
  end
else
  desc "Run RSpec code examples with rcov"
  RSpec::Core::RakeTask.new(:rcov) do |spec|
    spec.pattern = FileList['spec/**/*_spec.rb']
    exclude_files = [
      "gems",
    ]
    spec.rcov_opts = ['--exclude', exclude_files.join(",")]
    spec.rcov = true
  end
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
