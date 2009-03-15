# -*- coding: utf-8 -*-

def fib(n)i=0;j=1;n.times{j=i+i=j};i end
module Termtter::Client
  register_command(
    :name => :fib,
    :exec_proc => lambda {|arg|
      n = arg.to_i
      text = "fib(#{n}) = #{fib n}"
      Termtter::API.twitter.update(text)
      puts "=> " << text
    }
  )
  register_command(
    :name => :fibyou,
    :exec_proc => lambda {|arg|
      p arg
      /(\w+)\s(\d+)/ =~ arg
      name = $1
      p name
      n = $2.to_i
      text = "@#{name} fib(#{n}) = #{fib n}"
      Termtter::API.twitter.update(text)
      puts "=> " << text
    },
    :completion_proc => lambda {|cmd, arg|
      find_user_candidates arg, "#{cmd} %s"
    }
  )
end
