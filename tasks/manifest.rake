require 'find'

desc 'Generate manifest task'
manifestfile = "Manifest.txt"
task :manifest do |t|
  open( manifestfile , "wb" ) do |out|
    Dir[
        'lib/**/*.rb',
        'test/*',
        'bin/*',
        'run_termtter.rb',
        'History.txt',
        'Manifest.txt',
        'PostInstall.txt',
        'README.rdoc',
        'Rakefile'
    ].sort.each do |f|
      if File.file?( f )
        out.print f , "\n"
      end
    end
  end
  puts "Generate Manifest.txt"
end
