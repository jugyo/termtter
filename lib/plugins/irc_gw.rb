# -*- coding: utf-8 -*-

require 'net/irc'

# TODO: post text of stdout too

config.plugins.irc_gw.set_default(:port, 16669)

class TermtterIrcGateway < Net::IRC::Server::Session
  @@listners = []
  @@last_statuses = []

  Termtter::Client.register_hook(
    :name => :irc_gw,
    :point => :output,
    :exec => lambda { |statuses, event|
      if event == :update_friends_timeline
        @@last_statuses = (@@last_statuses + statuses.dup).reverse![0..100].reverse!
      end

      @@listners.each do |listner|
        listner.call(statuses.dup, event)
      end
    }
  )

  def server_name; 'termtter' end
  def server_version; '0.0.0' end
  def main_channel; '#termtter' end

  def initialize(*args)
    super
    @@listners << self
    Thread.start do
      sleep 1
      self.call(@@last_statuses || [], :update_friends_timeline)
    end
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
      post s.user.screen_name, msg_type, main_channel, s.text
    end
  end

  def on_message(m)
    begin
      termtter_command = m.command.downcase + ' ' + m.params.join(' ')
      unless Termtter::Client.find_commands(termtter_command).empty?
        post '#termtter', NOTICE, main_channel, '> ' + termtter_command
        Termtter::Client.call_commands(termtter_command)
      end
    rescue Termtter::CommandNotFound => e
      super
    end
  end

  def on_user(m)
    super
    post @prefix, JOIN, main_channel
  end

  def on_privmsg(m)
    target, message = *m.params
    Termtter::Client.call_commands('update ' + message)
  end
end

unless defined? IRC_SERVER
  IRC_SERVER = Net::IRC::Server.new(
    'localhost',
    config.plugins.irc_gw.port,
    TermtterIrcGateway,
    :logger => Termtter::Client.logger
  )
  Thread.start do
    IRC_SERVER.start
  end
end
