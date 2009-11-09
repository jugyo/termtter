# -*- coding: utf-8 -*-

def primes(n)
  return "" if n < 3
  table = []
  (2 .. n).each do |i|
    table << i
  end

  prime = []
  loop do
    prime << table[0]
    table = table.delete_if {|x| x % prime.max == 0 }
    break if table.max < (prime.max ** 2)
  end

  r = (table+prime).sort {|a, b| a<=>b }
  r.join(', ')
end

module Termtter::Client
  register_command(
    :name => :primes,
    :exec_proc => lambda {|arg|
      n = arg.to_i
      text = "primes(#{n}) = {#{primes n}}"
      puts "=> " << text
    }
  )
end
