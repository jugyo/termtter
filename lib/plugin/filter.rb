
module Termtter::Client

  public_storage[:filters] = []

  add_help 'filter FILE', 'Apply a filter'
  add_command /^filter\s+(.*)/ do |m, t|
    begin
      result = filter m[1].strip
    rescue LoadError
      result = false
    ensure
      puts "=> #{result.inspect}"
    end
  end

  add_help 'unfilter', 'Clear all filters'
  add_command /^unfilter\s*$/ do |m, t|
    clear_filters
    public_storage[:filters].clear
    puts '=> filter cleared'
  end

  add_help 'filters', 'Show list of applied filters'
  add_command /^filters\s*$/ do |m, t|
    unless public_storage[:filters].empty?
      puts public_storage[:filters].join(', ')
    else
      puts 'no filter was applied'
    end
  end

  def self.find_filter_candidates(a, b, filters)
    if a.empty?
      filters.to_a
    else
      filters.grep(/^#{Regexp.quote a}/i)
    end.
    map {|u| b % u }
  end

  filters = Dir["#{File.dirname(__FILE__)}/../filter/*.rb"].map do |f|
    f.match(%r|([^/]+).rb$|)[1]
  end
  add_completion do |input|
    if input =~ /^(filter)\s+(.*)/
      find_filter_candidates $2, "#{$1} %s", filters
    else
      %w[ filter filters unfilter ].grep(/^#{Regexp.quote input}/)
    end
  end
end

# filter.rb
#   a dynamic filter loader
# example
#   > list
#   (15:49:00) termtter: こんにちは
#   (15:48:02) termtter: hello
#   > filter english
#   => true
#   > list
#   (15:48:02) termtter: hello
# vim: fenc=utf8
