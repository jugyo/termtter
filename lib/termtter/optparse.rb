OptionParser.new { |opt|
  opt.on('-f', '--file config_file', 'Set path to configfile') do |val|
    config.system.__assign__(:conf_file, val)
  end
  opt.on('-t', '--termtter-directory directory', 'Set termtter directory') do |val|
    config.system.__assign__(:conf_dir, val)
  end
  opt.on('-d', '--devel', 'Start in developer mode') do |flg|
    config.system.__assign__(:devel, true) if flg
  end

  Version = Termtter::VERSION
  opt.parse!(ARGV)
}
