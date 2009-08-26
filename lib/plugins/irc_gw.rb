# -*- coding: utf-8 -*-

require 'net/irc'

# TODO: post text of stdout too

config.plugins.irc_gw.set_default(:port, 16669)
config.plugins.irc_gw.set_default(:last_statuses_count, 100)

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
        NOTICE
      end

    statuses.each do |s|
      typable_id = Termtter::Client.data_to_typable_id(s.id)
      post s.user.screen_name, msg_type, main_channel, [s.text, typable_id].join(' ')
    end
  end

  def on_message(m)
    termtter_command = m.command.downcase + ' ' + m.params.join(' ')
    unless Termtter::Client.find_commands(termtter_command).empty?
      post '#termtter', NOTICE, main_channel, '> ' + termtter_command
      Termtter::Client.call_commands(termtter_command)
    end
  end

  def on_user(m)
    super
    post @prefix, JOIN, main_channel
    post server_name, MODE, main_channel, "+o", @prefix.nick
    self.call(@@last_statuses || [], :update_friends_timeline)
  end

  def on_privmsg(m)
    target, message = *m.params
    Termtter::Client.call_commands('update ' + message)
  end

  def log(str)
    str.each_line do |line|
      post server_name, NOTICE, main_channel, line
    end
  end
end

unless defined? IRC_SERVER
  logger = Logger.new($stdout)
  logger.level = Logger::ERROR
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
