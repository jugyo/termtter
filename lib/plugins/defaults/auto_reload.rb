# -*- coding: utf-8 -*-
auto_reload_proc = lambda do
  begin
    Termtter::Client.execute('reload -r')
  rescue TimeoutError
    # do nothing
  rescue Exception => e
    Termtter::Client.handle_error(e)
  end
end

Termtter::Client.add_task(
  :name => :auto_reload,
  :interval => config.update_interval,
  :after => config.update_interval,
  &auto_reload_proc
)

Termtter::Client.register_hook(
  :name => :auto_reload_init,
  :point => :initialize,
  :exec => auto_reload_proc
)
