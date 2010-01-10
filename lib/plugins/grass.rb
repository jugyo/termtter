# -*- coding: utf-8 -*-
module Termtter
  module Client

    config.plugins.grass.set_default(:rate, 0)

    register_command(
      :name => :w, :aliases => [:grass],
      :exec_proc => lambda {|arg|
        arg, rate = arg.split(/ /)
        count = arg =~ /^[0-9]+$/ ? arg.to_i : 3
        rate ||= config.plugins.grass.rate
        grow = (count * rate.to_i).quo(100).round
        grasses = ('w' * (count-grow) + 'W' * grow).split(//).shuffle.join
        execute("update #{grasses}")
      },
      :help => ['grass, w', 'Grass it!']
    )
  end
end

# usage
# > w 10
# => wwwwwwwwww
#
# see also
#   http://d.hatena.ne.jp/tomisima/20090204/1233762301
