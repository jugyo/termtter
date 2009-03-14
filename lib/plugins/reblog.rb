# -*- coding: utf-8 -*-

require 'rubygems'
require 'tumblr'

module Termtter::Client
  register_command(
    :name => :reblog, :aliases => [],
    :exec_proc => lambda {|arg|
      if arg =~ /^reblog\s+(\d+)(.*)$/
        id = $1.strip
        comment = $2.strip
        statuses = public_storage[:log].select { |s| s.id == id }
        unless statuses.empty?
          status = statuses.first
        else
          status = t.show(id).first
        end
    
        Tumblr::API.write(config.plugins.reblog.email, config.plugins.reblog.password) do
          quote("#{status.text}", "<a href=\"http://twitter.com/#{status.user_screen_name}/status/#{status.id}\">Twitter / #{status.user_name}</a>")
        end
      end
    },
    :completion_proc => lambda {|cmd, args|
      if args =~ /^(\d*)$/
        find_status_id_candidates $1, "#{cmd} %s"
      end
    },
    :help => ['reblog ID', 'Tumblr Reblog a status']
  )
end

# reblog.rb
# tumblr reblog it!
#
# config.plugins.reblog.email = 'your-email-on-tumblr'
# config.plugins.reblog.password = 'your-password-on-tumblr'
#
#   reblog 1114860346
