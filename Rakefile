$:.unshift File.dirname(__FILE__) + '/lib'

require 'spec/rake/spectask'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'termtter/version'

name = 'termtter'
version = Termtter::VERSION

spec = Gem::Specification.new do |s|
  s.name = name
  s.version = version
  s.summary = "Terminal based Twitter client."
  s.description = "Termtter is a terminal based Twitter client."
  s.files = %w(Rakefile README.rdoc History.txt) + Dir.glob("{lib,spec,test}/**/*")
  s.executables = ["kill_termtter", "termtter"]
  s.add_dependency("json_pure", ">= 1.1.3")
  s.add_dependency("highline", ">= 1.5.0")
  s.add_dependency("termcolor", ">= 0.3.1")
  s.add_dependency("rubytter", ">= 0.6.4")
  s.authors = %w(jugyo ujihisa)
  s.email = 'jugyo.org@gmail.com'
  s.homepage = 'http://wiki.github.com/jugyo/termtter'
  s.rubyforge_project = 'termtter'
  s.has_rdoc = true
  s.rdoc_options = ["--main", "README.rdoc", "--exclude", "spec"]
  s.extra_rdoc_files = ["README.rdoc", "History.txt"]
end

Rake::GemPackageTask.new(spec) do |p|
  p.need_tar = true
end

task :install => [ :package ] do
  sh %{sudo gem install pkg/#{name}-#{version}.gem}
end

task :uninstall => [ :clean ] do
  sh %{sudo gem uninstall #{name}}
end

desc 'run all specs'
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ['-c']
end

Rake::RDocTask.new do |t|
  t.rdoc_dir = 'rdoc'
  t.title    = "rest-client, fetch RESTful resources effortlessly"
  t.options << '--line-numbers' << '--inline-source' << '-A cattr_accessor=object'
  t.options << '--charset' << 'utf-8'
  t.rdoc_files.include('README.rdoc', 'lib/**/*.rb')
end

CLEAN.include [ 'pkg', 'rdoc' ]
