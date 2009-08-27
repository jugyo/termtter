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
end
