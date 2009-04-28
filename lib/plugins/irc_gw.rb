# -*- coding: utf-8 -*-

require 'net/irc'

# TODO: disable logger
# TODO: post text of stdout too

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
      # TODO: ここの処理、微妙です。on_message にはいろんな種類のメッセージが来るんです。。
      termtter_command = m.command.downcase + ' ' + m.params.join(' ')
      Termtter::Client.call_commands(termtter_command)
    end
  end
end

Thread.start do
  Net::IRC::Server.new(
    'localhost',
    16668, # TODO: => config
    TermtterIrcGateway,
    :logger => Termtter::Client.logger
  ).start
end
