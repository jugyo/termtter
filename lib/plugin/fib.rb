# -*- coding: utf-8 -*-

def fib(n)i=0;j=1;n.times{j=i+i=j};i end
module Termtter::Client
  register_command(
    :name => :fib,
    :exec_proc => lambda {|arg|
      n = arg.to_i
      text = "fib(#{n}) = #{fib n}"
      Termtter::API.twitter.update_status(text)
      puts "=> " << text
    }
  )
  register_command(
    :name => :fibyou,
    :exec_proc => lambda {|arg|
      /(\w+)\s(\d+)/ =~ arg
      name = $1
      n = $2.to_i
      text = "@#{name} fib(#{n}) = #{fib n}"
      Termtter::API.twitter.update_status(text)
      puts "=> " << text
    }
  )
end
