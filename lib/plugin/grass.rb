# -*- coding: utf-8 -*-
module Termtter
  module Client

    configatron.plugins.grass.set_default(:rate, 0)
    rate = configatron.plugins.grass.rate

    register_command(
      :name => :w, :aliases => [:grass],
      :exec_proc => lambda {|arg|
        count = arg =~ /^[0-9]+$/ ? arg.to_i : 3
        grasses = (1..count).map { rand(rate) == 1 ? 'W' : 'w' }
        call_commands("update #{grasses}")
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
