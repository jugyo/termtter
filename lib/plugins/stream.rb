# -*- coding: utf-8 -*-

require 'uri'
require 'tweetstream'
require 'lib/termtter/active_rubytter'

module Termtter::Client

  class << self
    def friends(max = 1/0.0)
      user_name = config.user_name

      friends = []
      page = 0
      begin
        friends += tmp = Termtter::API::twitter.friends(user_name, :page => page+=1)
        p friends.length
      rescue
      end until (tmp.empty? or friends.length > max)
      friends.take(max)
    end
  end

  register_command(:stream) do |arg|

    targets = arg.split.map do |name|
      Termtter::API.twitter.user(name).id
    end

    if targets.empty?
      targets = friends(370)
      p targets.map(&:screen_name)
      targets = targets.map(&:id)
    end

    stream = Thread.new do
      TweetStream::Client.new(config.user_name, config.password).
        filter(:follow => targets) do |status|
          output [Termtter::ActiveRubytter.new(status)], :stream_output
        end
    end

    at_exit do
      stream.kill
    end
  end
end

