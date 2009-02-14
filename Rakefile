$:.unshift File.dirname(__FILE__) + '/lib'
require 'termtter'

require 'spec/rake/spectask'
desc 'run all specs'
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ['-c']
end

desc 'Generate gemspec'
task :gemspec do |t|
  open('termtter.gemspec', "wb" ) do |file|
    file << <<-EOS
Gem::Specification.new do |s|
  s.name = 'termtter'
  s.version = '#{Termtter::VERSION}'
  s.summary = "Terminal based Twitter client"
  s.description = "Termtter is a terminal based Twitter client"
  s.files = %w( #{Dir['lib/**/*.rb'].join(' ')}
                #{Dir['spec/**/*.rb'].join(' ')}
                #{Dir['test/**/*.rb', 'test/**/*.json'].join(' ')}
                README.rdoc
                History.txt
                Rakefile )
  s.executables = ["kill_termtter", "termtter"]
  s.add_dependency("json_pure", ">= 1.1.3")
  s.add_dependency("configatron", ">= 2.2.2")
  s.add_dependency("highline", ">= 1.5.0")
  s.authors = %w(jugyo ujihisa)
  s.email = 'jugyo.org@gmail.com'
  s.homepage = 'http://wiki.github.com/jugyo/termtter'
  s.rubyforge_project = 'termtter'
  s.has_rdoc = true
  s.rdoc_options = ["--main", "README.rdoc", "--exclude", "spec"]
  s.extra_rdoc_files = ["README.rdoc", "History.txt"]
end
    EOS
  end
  puts "Generate gemspec"
end

desc 'Generate gem'
task :gem => :gemspec do |t|
  system 'gem', 'build', 'termtter.gemspec'
end
