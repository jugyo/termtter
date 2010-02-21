require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = 'termtter'
    gem.summary = "Terminal based Twitter client."
    gem.description = "Termtter is a terminal based Twitter client."
    gem.executables = ["termtter"]
    gem.add_dependency("json", ">= 1.1.3")
    gem.add_dependency("highline", ">= 1.5.0")
    gem.add_dependency("termcolor", ">= 1.0.0")
    gem.add_dependency("rubytter", ">= 0.11.0")
    gem.add_dependency("notify", ">= 0.2.1")
    gem.authors = %w(jugyo ujihisa)
    gem.email = 'jugyo.org@gmail.com'
    gem.homepage = 'http://termtter.org/'
    gem.rubyforge_project = 'termtter'
    gem.has_rdoc = true
    gem.rdoc_options = ["--main", "README.rdoc", "--exclude", "spec"]
    gem.extra_rdoc_files = ["README.rdoc", "ChangeLog"]
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "jeweler_test #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
