# -*- coding: utf-8 -*-
module Termtter::Client
  add_task(:name => :update_timeline, :interval => config.update_interval, :after => config.update_interval) do
    call_commands('reload')
  end

  call_commands('reload')
end
