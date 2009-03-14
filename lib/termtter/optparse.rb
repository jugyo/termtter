OptionParser.new { |opt|
  Version = Termtter::VERSION
  opt.parse!(ARGV)
}
