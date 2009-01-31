# -*- coding: utf-8 -*-



module Termtter::Client

  public_storage[:filters] = []

  filters = Dir["#{File.dirname(__FILE__)}/../filter/*.rb"].map do |f|

    f.match(%r|([^/]+).rb$|)[1]

  end



  register_command(

    :name => :filter, :aliases => [],

    :exec_proc => proc {|arg|

      begin

        result = filter arg.strip

      rescue LoadError

        result = false

      ensure

        puts "=> #{result.inspect}"

      end

    },

    :completion_proc => proc {|cmd, args|

      find_filter_candidates args, "#{cmd} %s", filters

    },

    :help => ['filter FILE', 'Apply a filter']

  )



  register_command(

    :name => :unfilter, :aliases => [],

    :exec_proc => proc {|arg|

      clear_filters

      public_storage[:filters].clear

      puts '=> filter cleared'

    },

    :help => ['ufilter', 'Clear all filters']

  )



  register_command(

    :name => :filters, :aliases => [],

    :exec_proc => proc {|arg|

      unless public_storage[:filters].empty?

        puts public_storage[:filters].join(', ')

      else

        puts 'no filter was applied'

      end

    },

    :help => ['filters', 'Show list of applied filters']

  )



  def self.find_filter_candidates(a, b, filters)

    if a.empty?

      filters.to_a

    else

      filters.grep(/^#{Regexp.quote a}/i)

    end.

    map {|u| b % u }

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
