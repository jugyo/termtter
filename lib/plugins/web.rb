# -*- coding: utf-8 -*-

module Termtter::Client
  unless Termtter::Client.respond_to?(:open_uri)
    plug 'uri-open' # FIXME: Actually it only needs Termtter::Client.open_uri method
  end

  helpmsg = 'USAGE: web [{username}|{id}]'
  register_command(
    :name => :web,
    :help => ['web', helpmsg],
    :exec_proc => lambda {|arg|
      case arg
      when ''
        puts helpmsg
      when /^\d+$/
        statusid = arg #Termtter::API.twitter.show($1)
        name = 'ujm' # FIXME: Do you know how to obtain the screen name of the status? I researched but I couldn't find how to do that yet.
        puts "not impemented yet"
        #Termtter::Client.open_uri "http://twitter.com/#{name}/#{statusid}"
      else
        name = normalize_as_user_name(arg)
        Termtter::Client.open_uri "http://twitter.com/#{name}"
      end
    }
  )
end
