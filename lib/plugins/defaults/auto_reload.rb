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
since_ids = {}
config.auto_reload_channels.each do |c,i|
  Termtter::Client.add_task(:name => "auto_reload_#{c}".to_sym, :interval => i) do
    begin
      unless c == Termtter::Client.now_channel
        #Termtter::Client.execute(Termtter::Client.channel_to_command(c))
        #
        #MEMO: 差分だけを表示するようにする
        args = since_ids[c] ? [{:since_id => since_ids[c]}] : []
        statuses = Termtter::API.call_by_channel(c, *args)
        unless statuses.empty?
          print "\e[0G" + "\e[K" unless win?
          since_ids[c] = statuses[0].id
          Termtter::Client.output(statuses, :"update_#{c}_timeline", c)
          Readline.refresh_line
        end
      end
    rescue TimeoutError
      # do nothing
    rescue Exception => e
      Termtter::Client.handle_error(e)
    end
  end
end
