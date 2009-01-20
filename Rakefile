%w[rubygems rake rake/clean fileutils newgem rubigen].each { |f| require f }
require File.dirname(__FILE__) + '/lib/termtter'

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.new('termtter', Termtter::VERSION) do |p|
  p.author = %w[jugyo hakobe motemen koichiro Sixeight mattn ujihisa yanbe hitode909 bubblegum].sort_by{|i|i.downcase}
  p.email = ['jugyo.org@gmail.com']
  p.changes              = p.paragraphs_of("History.txt", 0..1).join("\n\n")
  p.post_install_message = 'PostInstall.txt' # TODO remove if post-install message not required
  p.rubyforge_name       = p.name # TODO this is default value
  p.extra_deps         = [
    ['json'],
    ['configatron'],
    ['highline'],
  ]
  #p.extra_dev_deps = [
  #  ['newgem', ">= #{::Newgem::VERSION}"]
  #]
  
  p.clean_globs |= %w[**/.DS_Store tmp *.log]
  path = (p.rubyforge_name == p.name) ? p.rubyforge_name : "\#{p.rubyforge_name}/\#{p.name}"
  p.remote_rdoc_dir = File.join(path.gsub(/^#{p.rubyforge_name}\/?/,''), 'rdoc')
  p.rsync_args = '-av --delete --ignore-errors'
end

require 'newgem/tasks' # load /tasks/*.rake
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# task :default => [:spec, :features]

require 'spec/rake/spectask'
desc 'run all specs'
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ['-c']
end

def egrep(pattern)
  res = []
  Dir['**/*.rb'].each do |fn|
    count = 0
    open(fn) do |f|
      while line = f.gets
        count += 1
        if line =~ pattern
          res << [fn, count.to_s, line.gsub(/\A\s+/, '')]
        end
      end
    end
  end
  fmax = res.map {|i| i[0] }.map(&:size).max
  cmax = res.map {|i| i[1] }.map(&:size).max
  res.each do |fn, count, line|
    puts "%s :%s:%s" % [fn.ljust(fmax), count.rjust(cmax), line]
  end
end

desc "Look for TODO and FIXME tags in the code"
task :todo do
  egrep /(FIXME|TODO)/
end

