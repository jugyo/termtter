# -*- coding: utf-8 -*-
module Termtter::Client
  def self.train(length)
    text = "ε="
    length.times{ text << "⋤⋥" }
    text
  end

  register_command(:train, :help => ['train [LENGTH]', 'Post a train']) do |arg|
    length = arg.empty? ? 1 : arg.to_i
    result = Termtter::API.twitter.update(train(length))
    puts "=> " << result.text
  end

  register_command(:trainyou, :help => ['trainyou [USER] [LENGTH] [(Optional) MESSAGE]', 'Post a train for a user']) do |arg|
    /(\w+)\s(\d+).*/ =~ arg
    name = normalize_as_user_name($1)
    length = $2.to_i
    msg = $3
    result = Termtter::API.twitter.update("@#{name} #{train(length)}#{msg}")
    puts "=> " << result.text
  end
end

