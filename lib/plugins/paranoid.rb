# -*- coding: utf-8 -*-
module Termtter::Client
  register_command(
    :paranoid,
    :help => ['paranoid message', 'Something like `update`'],
    :alias => :pd) do |arg|
      str = arg.gsub(/\w+/, '@\0').gsub(/#@/, '#')
      result = Termtter::API.twitter.update(str)
      puts "paranoid'ed=> " << result.text
    end
end
