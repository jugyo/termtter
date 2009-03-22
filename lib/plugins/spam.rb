# -*- coding: utf-8 -*-

message = '*super spam time*'
Termtter::API.twitter.update(message)
puts "=> #{message}"

Termtter::Client.register_hook(
  :name => :span,
  :point => /^pre_exec/,
  :exec => lambda{|*arg|
    text = arg.join(' ')
    Termtter::API.twitter.update(text)
    puts "=> #{text}"
    false
  }
)
