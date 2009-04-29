# -*- coding: utf-8 -*-

require 'net/irc'

# TODO: disable logger
# TODO: post text of stdout too

config.plugins.irc_gw.set_default(:port, 16669)

class TermtterIrcGateway < Net::IRC::Server::Session
  attr_reader :server_name, :server_version
  def initialize(*args)
    super
    @server_name = 'termttergw'
    @server_version = '0.0.0'
    Termtter::Client.register_hook(
      :name => :irc_gw,
      :point => :output,
      :exec => lambda { |statuses, event|
        statuses.each do |s|
          post s.user.screen_name, PRIVMSG, '_', s.text
        end
      }
    )
  end

  def on_message(m)
    if @user
      begin
        # TODO: ここの処理、微妙です。on_message にはいろんな種類のメッセージが来るんです。。
        termtter_command = m.command.downcase + ' ' + m.params.join(' ')
        Termtter::Client.call_commands(termtter_command)
      rescue => e
        Termtter::Client.handle_error e
      end
    end
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
