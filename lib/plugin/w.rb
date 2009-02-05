# -*- coding: utf-8 -*-
module Termtter
  module Client
    register_command(
      :name => :w, :aliases => [],
      :exec_proc => proc {|arg|
        count = arg =~ /^[0-9]+$/ ? arg.to_i : 3
        call_commands("update #{"w"*count}")
      },
      :help => ['w', 'Grass it!']
    )
  end
end

# usage
# > w 10
# => wwwwwwwwww
#
# see also
#   http://d.hatena.ne.jp/tomisima/20090204/1233762301
