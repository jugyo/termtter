config.plugins.time_signal.set_default(:minutes, [0])

last_signal_time = nil

Termtter::Client.add_task(:name => :time_signal, :interval => 10) do
  begin
    now = Time.now
    if config.plugins.time_signal.minutes.include?(now.min)
      hour = now.strftime('%H:%M')
      unless hour == last_signal_time
        Termtter::Client.clear_line
        puts "<on_green> #{hour} </on_green>".termcolor
        Termtter::Client.notify 'time signal', hour
        Readline.refresh_line
        last_signal_time = hour
      end
    end
  rescue Exception => e
    Termtter::Client.handle_error(e)
  end
end
