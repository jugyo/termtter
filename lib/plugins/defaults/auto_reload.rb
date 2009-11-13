# -*- coding: utf-8 -*-
module Termtter::Client
  add_task(:name => :auto_reload, :interval => config.update_interval, :after => config.update_interval) do
    begin
      call_commands('reload -r')
    rescue Exception => e
      handle_error(e)
    end
  end

  register_hook(
    :name => :auto_reload_init,
    :point => :initialize,
    :exec => lambda {
      begin
        call_commands('reload -r')
      rescue Exception => e
        handle_error(e)
      end
    }
  )
end
