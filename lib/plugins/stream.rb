# -*- coding: utf-8 -*-

require 'uri'
require 'tweetstream'
require 'lib/termtter/active_rubytter'

config.plugins.stream.set_default :max_following, 400

module Termtter::Client

  class << self
    def friends(max = 1/0.0)
      Users.take(max).map{ |u| u.id}
    end
  end

  register_command(:stream) do |arg|

    stream = Thread.new do
      begin
        max = config.plugins.stream.max_following
        puts "streaming #{max} friends."
        p User.take(max).map(&:id)
        TweetStream::Client.new(config.user_name, config.password).
          filter(:follow => User.take(max).map(&:id)) do |status|
          output [Termtter::ActiveRubytter.new(status)], :stream_output
        end
      rescue => e
        p e
        puts "streaming seems broken."
        config.plugins.stream.max_following -= 10 if config.plugins.stream.max_following > 10
        retry
      end
    end

    at_exit do
      stream.kill
    end
  end
end

