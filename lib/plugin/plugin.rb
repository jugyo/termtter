module Termtter::Client

  public_storage[:plugins] = Dir["#{File.dirname(__FILE__)}/*.rb"].map do |f|
    f.match(%r|([^/]+).rb$|)[1]
  end

  add_help 'plugin FILE', 'Load a plugin'
  add_command /^plugin\s+(.*)/ do |m, t|
    begin
      result = plugin m[1]
    rescue LoadError
    ensure
      puts "=> #{result.inspect}"
    end
  end

  add_help 'plugins', 'Show list of plugins'
  add_command /^plugins$/ do |m, t|
    puts public_storage[:plugins].join("\n")
  end

  def self.find_plugin_candidates(a, b)
    if a.empty?
      public_storage[:plugins].to_a
    else
      public_storage[:plugins].grep(/^#{Regexp.quote a}/i)
    end.
    map {|u| b % u }
  end

  add_completion do |input|
    if input =~ /^(plugin)\s+(.*)/
      find_plugin_candidates $2, "#{$1} %s"
    else
      %w[ plugin plugins ].grep(/^#{Regexp.quote input}/)
    end
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
