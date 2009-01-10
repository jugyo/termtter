require 'zlib'

configatron.plugins.history.
  set_default(:filename, '~/.termtter_history')
configatron.plugins.history.
  set_default(:keys, [:log, :users, :status_ids])
configatron.plugins.history.
  set_default(:max_of_history, 100)

module Termtter::Client
  def self.load_history
    filename = File.expand_path(configatron.plugins.history.filename)
    keys = configatron.plugins.history.keys

    if File.exist?(filename)
      begin
        history = Marshal.load Zlib::Inflate.inflate(File.read(filename))
      rescue Zlib::DataError
        history = Marshal.load File.read(filename)
      end
      if history
        keys.each do |key|
          public_storage[key] = history[key] if history[key]
        end
        Readline::HISTORY.push *history[:history] if history[:history]
        puts "history loaded(#{File.size(filename)}bytes)"
      end
    end
  end

  def self.save_history
    filename = File.expand_path(configatron.plugins.history.filename)
    keys = configatron.plugins.history.keys
    history = { }
    keys.each do |key|
      history[key] = public_storage[key]
    end
    max_of_history = configatron.plugins.history.max_of_history
    history[:history] = Readline::HISTORY.to_a.uniq
    if history[:history].size > max_of_history
      history[:history] = history[:history][-max_of_history..-1]
    end

    File.open(filename, 'w') do |f|
      f.write Zlib::Deflate.deflate(Marshal.dump(history))
    end
    puts "history saved(#{File.size(filename)}bytes)"
  end

  add_hook do |statuses, event|
    case event
    when :initialize
      load_history
    when :exit
      save_history
    end
  end
end

# history.rb
#   save log to file
