# -*- coding: utf-8 -*-
module Termtter::Client
  register_command(:hi, :help => ['hi [(Optinal) USER]', 'Post a hi']) do |arg|
    result =
      if arg.empty?
        Termtter::API.twitter.update("hi")
      else
        name = normalize_as_user_name(arg)
        Termtter::API.twitter.update("hi @#{name}")
      end
    puts "=> " << result.text
  end
end
