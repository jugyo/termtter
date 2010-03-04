# -*- coding: utf-8 -*-
config.set_default(:auto_reload_channels,{})
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

config.auto_reload_channels.each do |c,i|
  Termtter::Client.add_task(:name => "auto_reload_#{c}".to_sym, :interval => i) do
    begin
      print "\e[0G" + "\e[K" unless win?
      Termtter::Client.execute(
        case c
        when :replies
          "replies"
        else
          "list #{c}"
        end
      )
      Readline.refresh_line
    rescue TimeoutError
      # do nothing
    rescue Exception => e
      Termtter::Client.handle_error(e)
    end
  end
end
