# -*- coding: utf-8 -*-
module Termtter::Client
  register_command(
    :name => :_update_timeline,
    :exec_proc => lambda {|arg|
      begin
        args = @since_id ? [{:since_id => @since_id}] : []
        statuses = Termtter::API.twitter.friends_timeline(*args)
        unless statuses.empty?
          print "\e[1K\e[0G" unless win?
          @since_id = statuses[0].id
          output(statuses, :update_friends_timeline)
          Readline.refresh_line
        end
      rescue OpenURI::HTTPError => e
        if e.message == '401 Unauthorized'
          puts 'Could not login'
          puts 'plese check your account settings'
          exit!
        end
      rescue => e
        handle_error(e)
      end
    }
  )

  add_task(:name => :update_timeline, :interval => config.update_interval, :after => config.update_interval) do
    call_commands('_update_timeline')
  end

  call_commands('_update_timeline')
end
