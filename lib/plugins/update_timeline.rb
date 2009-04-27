# -*- coding: utf-8 -*-
module Termtter::Client

  add_task(:name => :update_timeline, :interval => config.update_interval, :after => config.update_interval) do
    call_commands('_update_timeline')
  end

  call_commands('_update_timeline')
end
