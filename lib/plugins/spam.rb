# -*- coding: utf-8 -*-

Termtter::API.twitter.update('*super spam time*')
Termtter::Client.register_hook(
  :name => :span,
  :points => [/^pre_exec/],
  :exec_proc => lambda{|*arg|
    text = arg.join(' ')
    Termtter::API.twitter.update(text)
    puts "=> #{text}"
    false
  }
)
