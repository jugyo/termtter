# -*- coding: utf-8 -*-

require 'uri'
require 'tweetstream'
require 'lib/termtter/active_rubytter'

config.plugins.stream.set_default :max_following, 400

module Termtter::Client

  class << self
    if defined?(DB)
      def friends(max = 999999)
        Status.group(:user_id).
          select(:user_id, :screen_name).
          join(:users, :id => :user_id).
          order(:COUNT.sql_function.desc).take(max)
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

      throw :exit unless config.plugins.stream.thread.empty?

      targets = args.map { |name|
        Termtter::API.twitter.user(name).id rescue nil
      }

      max = config.plugins.stream.max_following
      unless targets and targets.length > 0
        keys = [:user_id, :"`user_id`", :id, :"`id`"]
        targets = friends(max).map{ |u|
          keys.map{ |k| u[k] rescue nil}.compact.first
        }.compact
      end

      config.plugins.stream.thread = Thread.new do
        begin
          current_targets = targets.take(max)
          targets = targets.take(max)
          puts "streaming #{current_targets.length} friends."
          TweetStream::Client.new(config.user_name, config.password).
            filter(:follow => current_targets) do |status|
            output [Termtter::ActiveRubytter.new(status)], :stream_output
          end
        rescue(NoMethodError) => e    # #<NoMethodError: private method `split' called for nil:NilClass>
          puts "stream seems broken (#{e.inspect})."
          max -= 10 if max > 10
          retry
        end
      end

      at_exit do
        config.plugins.stream.thread.kill
      end
    end
  end
end

