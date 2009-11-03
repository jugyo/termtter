# -*- coding: utf-8 -*-

require 'uri'
require 'tweetstream'
require 'lib/termtter/active_rubytter'

config.plugins.stream.set_default :max_following, 400

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
    config.plugins.stream.thread = Thread.new do
      begin
        max = config.plugins.stream.max_following
        targets = friends(max).map{ |u| u[:"`user_id`"]}
        p friends(max).map{ |u| u[:"`screen_name`"]}
        puts "streaming #{targets.length} friends."
        TweetStream::Client.new(config.user_name, config.password).
          filter(:follow => targets) do |status|
          output [Termtter::ActiveRubytter.new(status)], :stream_output
        end
      rescue => e
        p e
        puts "streaming seems broken."
        config.plugins.stream.max_following -= 10 if config.plugins.stream.max_following > 10
        retry
      end
    end

    catch(:exit) do
      args = arg.split

      case args[0]
      when ':stop'
        config.plugins.stream.followed_users = []
        config.plugins.stream.thread.kill rescue nil
        puts 'stream is down'
        throw :exit
      when ':followers'
        p config.plugins.stream.followed_users
        throw :exit
      end

      throw :exit if config.plugins.stream.thread.alive?

      targets = args.map do |name|
        Termtter::API.twitter.user(name).id
      end

      if targets.empty?
        id_method =  defined?(DB) ? :user_id : :id

        config.plugins.stream.followed_users = []
        friends(370).each do |t|
          config.plugins.stream.followed_users << t[:screen_name]
          targets << t.__send__(id_method)
        end
        p config.plugins.stream.followed_users
      end

      at_exit do
        config.plugins.stream.thread.kill
      end
    end
  end
end

