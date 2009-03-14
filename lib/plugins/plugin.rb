# -*- coding: utf-8 -*-

module Termtter::Client

  public_storage[:plugins] = Dir["#{File.dirname(__FILE__)}/*.rb"].map do |f|
    f.match(%r|([^/]+).rb$|)[1]
  end

  register_command(
    :name      => :plugin, :aliases => [],
    :exec_proc => lambda {|arg|
      begin
        result = plugin arg.strip
      rescue LoadError
      ensure
        puts "=> #{result.inspect}"
      end
    },
    :completion_proc => lambda {|cmd, args|
      find_user_candidates args, "#{cmd} %s"
      unless args.empty?
        find_plugin_candidates args, "#{cmd} %s"
      else
        public_storage[:plugins].sort
      end
    },
    :help      => ['plugin FILE', 'Load a plugin']
  )

  register_command(
    :name      => :plugins, :aliases => [],
    :exec_proc => lambda {|arg|
      puts public_storage[:plugins].sort.join("\n")
    },
    :help      => ['plugins', 'Show list of plugins']
  )

  def self.find_plugin_candidates(a, b)
    public_storage[:plugins].
      grep(/^#{Regexp.quote a}/i).
      map {|u| b % u }
  end
end

# plugin.rb
#   a dynamic plugin loader
# example
#   > u <%= not erbed %>
#   => <%= not erbed %>
#   > plugin erb
#   => true
#   > u <%= 1 + 2 %>
#   => 3
