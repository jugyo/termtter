require 'stringio'
module Termtter::Client
  register_command(
    'capture',
    :alias => 'cap',
    :help => ['capture FILENAME COMMAND', 'capture the output of command to file']
  ) do |args|
    org = $stdout
    begin
      filename, command = args.split(/\s+/, 2)
      $stdout = io = StringIO.new
      execute(command)
    ensure
      $stdout = org
    end

    File.open(filename, 'a') do |file|
      file << io.string.gsub(/\e\[\d+m/, '')
    end
    puts "=> #{filename.inspect}"
  end
end
