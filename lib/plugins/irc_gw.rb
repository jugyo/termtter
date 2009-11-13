# -*- coding: utf-8 -*-

require 'net/irc'

config.plugins.irc_gw.set_default(:port, 16669)
config.plugins.irc_gw.set_default(:last_statuses_count, 100)
config.plugins.irc_gw.set_default(:logger_level, Logger::ERROR)

module Termtter::Client
  class << self
    def following_friends
      user_name = config.user_name

      frinends = []
      page = 0
      begin
        frinends += tmp = Termtter::API::twitter.friends(user_name, :page => page+=1)
      end until tmp.empty?
      frinends.map(&:screen_name)
    end
  end
end

class TermtterIrcGateway < Net::IRC::Server::Session
  @@listners = []
  @@last_statuses = []

  Termtter::Client.register_hook(
    :name => :irc_gw,
    :point => :output,
    :exec => lambda { |statuses, event|
      if event == :update_friends_timeline
        @@last_statuses = 
          (@@last_statuses + statuses.dup).reverse![0..config.plugins.irc_gw.last_statuses_count].reverse!
      end

      @@listners.each do |listner|
        listner.call(statuses.dup, event)
      end
    }
  )
  if Termtter::Client.respond_to? :register_output
    Termtter::Client.register_output(:irc) do |message|
      @@listners.each do |listener|
        listener.log(message.gsub(/\e\[\d+m/, '')) # remove escape sequence
      end
    end
  end

  def server_name; 'termtter' end
  def server_version; '0.0.0' end
  def main_channel; '#termtter' end

  def initialize(*args)
    super
    @@listners << self
  end

  def call(statuses, event)
    msg_type =
      case event
      when :update_friends_timeline
        PRIVMSG
      else
        time_format = Termtter::Client.time_format_for statuses
        NOTICE
      end
    statuses.each do |s|
      typable_id = Termtter::Client.data_to_typable_id(s.id)
      time = Time.parse(s.created_at).strftime(time_format) if time_format
      post s.user.screen_name, msg_type, main_channel, [time, s.text, typable_id].compact.join(' ')
    end
  end

  def on_message(m)
    termtter_command = m.command.downcase + ' ' + m.params.join(' ')
    return if Termtter::Client.find_commands(termtter_command).empty?
    post '#termtter', NOTICE, main_channel, '> ' + termtter_command
    Termtter::Client.call_commands(termtter_command)
  rescue Exception => e
    post '#termtter', NOTICE, main_channel, "#{e.class.to_s}: #{e.message}"
    Termtter::Client.handle_error(e)
  end

  def on_user(m)
    super
    post @prefix, JOIN, main_channel
    post server_name, MODE, main_channel, "+o", @prefix.nick
    check_friends
    self.call(@@last_statuses || [], :update_friends_timeline)
  end

  def on_privmsg(m)
    target, message = *m.params
    Termtter::Client.call_commands('update ' + message)
    post @prefix, TOPIC, main_channel, message
  rescue Exception => e
    post '#termtter', NOTICE, main_channel, "#{e.class.to_s}: #{e.message}"
    Termtter::Client.handle_error(e)
  end

  def log(str)
    str.each_line do |line|
      post server_name, NOTICE, main_channel, line
    end
  end

  def check_friends
    params = []
    max_params_count = 3
    Termtter::Client.following_friends.each do |name|
      prefix = Prefix.new("#{name}!#{name}@localhost")
      post prefix, JOIN, main_channel
      params << prefix.nick
      next if params.size < max_params_count

      post server_name, MODE, main_channel, "+#{"v" * params.size}", *params
      params = []
    end
    post server_name, MODE, main_channel, "+#{"v" * params.size}", *params unless params.empty?
  end
end

unless defined? IRC_SERVER
  logger = Logger.new($stdout)
  logger.level = config.plugins.irc_gw.logger_level
  IRC_SERVER = Net::IRC::Server.new(
    'localhost',
    config.plugins.irc_gw.port,
    TermtterIrcGateway,
    :logger => logger
  )
  Thread.start do
    IRC_SERVER.start
  end
end
