# -*- coding: utf-8 -*-
module Termtter::Client
  add_task(:name => :auto_reload, :interval => config.update_interval, :after => config.update_interval) do
    call_commands('reload')
  end

  register_hook(
    :name => :auto_reload_init,
    :point => :initialize,
    :exec => lambda { call_commands('reload') }
  )
end
