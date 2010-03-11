# -*- coding: utf-8 -*-
module Termtter::Client
  [:hi, :hola].each do |hi|
    register_command(hi, :help => ["#{hi} [(Optinal) USER]", "Post a #{hi}"]) do |arg|
      result =
        if arg.empty?
          Termtter::API.twitter.update(hi.to_s)
        else
          name = normalize_as_user_name(arg)
          Termtter::API.twitter.update("@#{name} #{hi}")
        end
      puts "=> " << result.text
    end
  end
end
