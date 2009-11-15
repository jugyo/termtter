# -*- coding: utf-8 -*-
module Termtter::Client
  last_line_buffer = nil
  input_checker_interval = config.update_interval / 10

  add_task(:name => :input_checker, :interval => input_checker_interval, :after => config.update_interval) do
    last_line_buffer = Readline.line_buffer
  end

  reload_proc = lambda do
    begin
      if last_line_buffer == Readline.line_buffer
        call_commands('reload -r')
      else
        add_task(:name => :re_auto_reload, :after => input_checker_interval, &reload_proc)
      end
    rescue Exception => e
      handle_error(e)
    end
  end

  add_task(
    :name => :auto_reload,
    :interval => config.update_interval,
    :after => config.update_interval,
    &reload_proc
  )

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
