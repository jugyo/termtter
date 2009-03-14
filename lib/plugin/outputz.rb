# -*- coding: utf-8 -*-


module Termtter::Client
  config.plugins.outputz.set_default(:uri, 'termtter://twitter.com/status/update')

  key = config.plugins.outputz.secret_key
  if key.instance_of? ::Termtter::Config::Storage
    puts 'Need your secret key'
    puts 'please set config.plugins.outputz.secret_key'
  else
    add_command /^(update|u)\s+(.*)/ do |m, t|
      text = ERB.new(m[2]).result(binding).gsub(/\n/, ' ')
      unless text.empty?
        t.update_status(text)
        puts "=> #{text}"
      end
      t.instance_variable_get('@connection').
        start('outputz.com', 80) do |http|
          key  = CGI.escape key
          uri  = CGI.escape config.plugins.outputz.uri
          size = text.split(//).size
          http.post('/api/post', "key=#{key}&uri=#{uri}&size=#{size}")
        end
    end
  end
end

# outputz.rb
#   a plugin that report to outputz your post
#
# settings (note: must this order)
#   config.plugins.outputz.secret_key = 'your secret key'
#   plugin 'outputz'

