# -*- coding: utf-8 -*-

module Termtter::Client
  config.plugins.outputz.set_default(:uri, 'termtter://twitter.com/status/update')

  key = config.plugins.outputz.secret_key
  if key.empty?
    puts 'Need your secret key'
    puts 'please set config.plugins.outputz.secret_key'
  else
    register_hook(
      :name => :outputz,
      :points => [:pre_exec_update],
      :exec_proc => lambda {|cmd, arg|
        Thead.new do
          Termtter::API.connection.start('outputz.com', 80) do |http|
              key  = CGI.escape key
              uri  = CGI.escape config.plugins.outputz.uri
              size = arg.split(//).size
              http.post('/api/post', "key=#{key}&uri=#{uri}&size=#{size}")
            end
        end
      }
    )
  end
end

# outputz.rb
#   a plugin that report to outputz your post
#
# settings (note: must this order)
#   config.plugins.outputz.secret_key = 'your secret key'
#   plugin 'outputz'
