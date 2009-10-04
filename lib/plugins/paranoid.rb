# -*- coding: utf-8 -*-
module Termtter::Client
  register_command(:paranoid, :help => ['paranoid message', 'Something like `update`']) do |arg|
    str = arg.inspect
    result = Termtter::API.twitter.update(str)
    puts "=> " << result.text
  end
end
