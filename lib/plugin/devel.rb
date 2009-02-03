# -*- coding: utf-8 -*-

module Termtter::Client
  # TODO: use register_command
  add_command /^eval\s+(.*)$/ do |m, t|
    begin
      result = eval(m[1]) unless m[1].empty?
      puts "=> #{result.inspect}"
    rescue SyntaxError => e
      puts e
    end
  end
end
