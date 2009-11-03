# -*- coding: utf-8 -*-

require 'uri'
require 'tweetstream'
require 'lib/termtter/active_rubytter'

module Termtter::Client

  class << self
    if defined?(DB)
      def friends(max = 1/0.0)
        Status.group(:user_id).
          select(:user_id, :screen_name).
          join(:users, :id => :user_id).
          order(:COUNT.sql_function.desc).
          take(max)
      end
    else
      def friends(max = 1/0.0)
        friends = []
        page    = 0
        begin
          friends += tmp = Termtter::API::twitter.friends(config.user_name, :page => page+=1)
          p friends.length
        rescue
        end until (tmp.empty? or friends.length > max)
        friends.take(max)
      end
    end
  end

  register_command(:stream) do |arg|

    targets = arg.split.map do |name|
      Termtter::API.twitter.user(name).id
    end

    if targets.empty?
      if defined?(DB)
        names = []
        friends(370).each do |t|
          names << t[:screen_name]
          targets << t.user_id
        end
        p names
      else
        names = []
        friends(370).each do |t|
          names << t.screen_name
          targets << t.id
        end
        p names
      end
    end


    config.plugins.stream.thread = Thread.new do
      TweetStream::Client.new(config.user_name, config.password).
        filter(:follow => targets) do |status|
          output [Termtter::ActiveRubytter.new(status)], :stream_output
        end
    end

    at_exit do
      config.plugins.stream.thread.kill
    end
  end

  register_command(:stop_stream) do |args|
    config.plugins.stream.thread.kill
  end
end

