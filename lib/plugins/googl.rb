# -*- coding: utf-8 -*-
require 'googl'

Termtter::Client.register_hook(
  :name => :googlURL, 
  :points => [:modify_arg_for_update, :modify_arg_for_reply],
  :exec => lambda do |cmd, arg|

  if( arg =~ /(http[s]?:\/\/.) / )
    url = $1
    client = Googl.client('email@account','password')
    arg.gsub(/(http[s]?:\/\/.) /,client.shorten(url).short_url+' ')
  else
    arg
  end
end
)
