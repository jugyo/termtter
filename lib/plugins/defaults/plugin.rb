module Termtter::Client
  register_command('plugin edit') do |arg|
    if /\-s/ =~ arg
      arg = arg.sub('-s', '').strip
      include_system_plugins = true
    end

    if path = search_plugin_file(arg, include_system_plugins)
      open_editor(path)
      plug(arg)
      puts "reload => #{arg}"
    else
      puts TermColor.parse('<red>Plugin not found :(</red>')
    end
  end

  register_command('plugin show') do |arg|
    if path = search_plugin_file(arg, true)
      puts IO.read(path)
    else
      puts TermColor.parse('<red>Plugin not found :(</red>')
    end
  end

  register_command('plugin create') do |arg|
    raise 'Not implement!'
  end

  def self.open_editor(path)
    # TODO: change to common method or use launchy
    system ENV['EDITOR'] || 'vim', path
  end

  def self.search_plugin_file(name, include_system_plugins = false)
    regex = /#{Regexp.quote(name + '.rb')}$/
    plugin_files(include_system_plugins).detect {|f| regex =~ f}
  end

  def self.plugin_files(include_system_plugins = false)
    files = Dir["#{Termtter::CONF_DIR}/plugins/*.rb"]
    files += Dir["#{File.expand_path(File.dirname(__FILE__))}/*.rb"] if include_system_plugins
    files
  end

  # TODO: rename command 'plug' to 'plugin load' and define 'plug' as alias
  # TODO: completion for plugin names
end

