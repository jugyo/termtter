require 'yaml'

configatron.plugins.history.set_default('filename',
                                        '~/.termtter_history')
configatron.plugins.history.set_default('keys',
                                        [:log, :users, :status_ids])

module Termtter::Client
  def self.load_history
    filename = File.expand_path(configatron.plugins.history.filename)
    keys = configatron.plugins.history.keys

    if File.exist?(filename)
      history = YAML.load_file(filename)
      if history
        keys.each do |key|
          public_storage[key] = history[key] if history[key]
        end
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

    YAML.dump( history, File.open(filename, 'w') )
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
