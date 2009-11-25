# -*- coding: utf-8 -*-

require 'tweetstream'
require File.dirname(__FILE__) + '/../termtter/active_rubytter'

config.plugins.stream.set_default :max_following, 400
config.plugins.stream.set_default :timeline_format, '<yellow>[S]</yellow> $orig'
config.plugins.stream.set_default :retry_wait_base, 60
config.plugins.stream.set_default :retry_wait_max, 3600

module Termtter::Client

  config.plugins.stream.keywords = []

  class << self
    if defined?(DB)
      def friends(max)
        Status.group(:user_id).
          select(:user_id, :screen_name).
          join(:users, :id => :user_id).
          order(:COUNT.sql_function.desc).take(max)
      end
    else
      def friends(max)
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

    def swap_timeline_format(format)
      original = config.plugins.stdout.timeline_format
      if /\$orig/ =~ format
        format.gsub!(/\$orig/, original)
      end
      config.plugins.stdout.timeline_format = format
      yield
      config.plugins.stdout.timeline_format = original
    end

    def kill_thread(name)
      config.plugins.stream.__send__(name).kill rescue nil
      config.plugins.stream.__assign__(name, nil)
    end
    def alive_thread?(name)
      config.plugins.stream.__send__(name).alive? rescue false
    end
    private :kill_thread
    private :alive_thread?
  end


  help = ['keyword_stream [:stop|:show|:add|:delete] [KEYWORDS]',
          'Tracking keyword using Stream API']
  register_command(:keyword_stream, :help => help) do |arg|
    catch(:exit) do
      throw :exit if arg.empty?
      args = arg.split /[, ]/
      case args[0]
      when ':stop'
        kill_thread :keyword_stream if alive_thread? :keywor_stream
        config.plugins.stream.keywords.clear
        puts 'keyword_stream has stopped'
        throw :exit
      when ':show'
        puts alive_thread?(:keyword_stream) ? 'streaming alive' : 'not alive'
        unless config.plugins.stream.keywords.empty?
          puts config.plugins.stream.keywords.join(', ')
        end
        throw :exit
      when ':add'
        args.shift
        config.plugins.stream.keywords |= args
      when ':delete'
        args.shift
        config.plugins.stream.keywords -= args
        if config.plugins.stream.keywords.empty?
          kill_thread :keyword_stream if alive_thread? :keywor_stream
          puts 'keyword_stream has stopped'
          throw :exit
        end
      when ':start'
      when /^:.*/
        puts "Unknown keyword_stream options"
        throw :exit
      else
        config.plugins.stream.keywords = args
      end

      kill_thread :keyword_stream if alive_thread? :keywor_stream

      keywords = config.plugins.stream.keywords

      puts "streaming: #{keywords.join(', ')}"
      config.plugins.stream.keyword_stream = Thread.new do
        retry_wait = config.plugins.stream.retry_wait_base,
        begin
          TweetStream::Client.new(config.user_name, config.password).
            filter(:track => keywords) do |status|
            print "\e[0G" + "\e[K" unless win?
            swap_timeline_format(config.plugins.stream.timeline_format) do
              output [Termtter::ActiveRubytter.new(status)],
                      :update_friends_timeline
            end
            Readline.refresh_line
          end
        rescue
          puts "stream is down"
          puts "wait #{config.plugins.stream.retry_wait}sec"
          sleep retry_wait
          retry_wait = retry_wait * 2;
          retry_wait = config.plugin.stream.retry_max unless
          retry_max > config.plugin.stream.retry_max
          retry
        end
      end
    end

    at_exit do
      kill_thread :keyword_stream
    end
  end

  help = ['hash_stream HASHTAG', 'Tracking hashtag using Stream API']
  register_command(:hash_stream, :help => help) do |arg|
    arg = "##{arg}" unless /^#/ =~ arg
    call_commands("keyword_stream #{arg}")
  end

  help = ['stream USERNAME', 'Tracking users using Stream API']
  register_command(:stream, :help => help) do |arg|
    catch(:exit) do
      args = arg.split

      case args[0]
      when ':stop'
        kill_thread :thread
        puts 'stream is down'
        throw :exit
      end

      if config.plugins.stream.thread.class == Thread
        puts 'already streaming'
        throw :exit
      end

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
          message = "streaming #{current_targets.length} friend"
          message << (current_targets.size == 1 ? '.' : 's.')
          puts message
          TweetStream::Client.new(config.user_name, config.password).
            filter(:follow => current_targets) do |status|
            print "\e[0G" + "\e[K" unless win?
            swap_timeline_format(config.plugins.stream.timeline_format) do
              output [Termtter::ActiveRubytter.new(status)], :update_friends_timeline
            end
            Readline.refresh_line
          end
        rescue(NoMethodError) => e    # #<NoMethodError: private method `split' called for nil:NilClass>
          puts "stream seems broken (#{e.inspect})."
          max -= 10 if max > 10
          retry
        end
      end

      at_exit do
        kill_thread :stream
      end
    end
  end
end

