# -*- coding: utf-8 -*-

require 'net/irc'

# TODO: disable logger
# TODO: post text of stdout too

config.plugins.irc_gw.set_default(:port, 16669)

class TermtterIrcGateway < Net::IRC::Server::Session
  def server_name; 'termtter' end
  def server_version; '0.0.0' end
  def main_channel; '#termtter' end

  def initialize(*args)
    super
    Termtter::Client.register_hook(
      :name => :irc_gw,
      :point => :output,
      :exec => lambda { |statuses, event|
        statuses.each do |s|
          post s.user.screen_name, PRIVMSG, main_channel, s.text
        end
      }
    )
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

Thread.start do
  Net::IRC::Server.new(
    'localhost',
    config.plugins.irc_gw.port,
    TermtterIrcGateway,
    :logger => Termtter::Client.logger
  ).start
end
