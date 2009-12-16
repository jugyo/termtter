# -*- coding: utf-8 -*-

Termtter::Client.register_command(
  :name => :gist,
  :exec => lambda {|arg|
    args = arg.split(' ')
    output = args[0] == '-p' ? 
      `#{args[1..-1].join(' ')} | gist -p` : 
      `#{args.join(' ')} | gist` 
    Termtter::API.twitter.update(output)
    puts "=> " <<output
  }
)

# gist.rb    : Executes command and creates gist with the output
# Depends on : http://github.com/defunkt/gist
# Usage      : gist command_to_execute
# Examples   :
#            > gist ls          (public gist)
#            > gist -p ifconfig (private gist)
