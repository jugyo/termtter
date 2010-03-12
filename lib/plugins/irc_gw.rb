# -*- coding: utf-8 -*-

require 'net/irc'
require 'set'

config.plugins.irc_gw.set_default(:port, 16669)
config.plugins.irc_gw.set_default(:last_statuses_count, 100)
config.plugins.irc_gw.set_default(:logger_level, Logger::ERROR)
config.plugins.irc_gw.set_default(:command_regexps, [/^(.+): *(.*)/])

Termtter::Client.plug 'multi_output'

module Termtter::Client
  class << self
    def following_friends
      user_name = config.user_name
      frinends  = []
      last = nil
      begin
        puts "collecting friends (#{frinends.length})"
        last = Termtter::API::twitter.friends(user_name, :cursor => last ? last.next_cursor : -1)
        frinends += last.users
      rescue Timeout::Error, StandardError # XXX
        break
      end until last.next_cursor == 0
      puts "You have #{frinends.length} friends."
      Set.new(frinends.map(&:screen_name))
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
        listener.log(message.to_s.gsub(/\e\[\d+m/, '')) # remove escape sequence
      end
    end
  end

  def server_name; 'termtter' end
  def server_version; '0.0.0' end
  def main_channel; '#termtter' end

  def initialize(*args)
    super
    @@listners << self
    @friends = Set.new
    @commands = []

    Termtter::Client.register_hook(:collect_user_names_for_irc_gw, :point => :pre_filter) do |statuses, event|
      new_users = []
      statuses.each do |s|
        screen_name = s.user.screen_name
        next if screen_name == @user # XXX
        next if @friends.include? screen_name
        @friends << screen_name
        new_users << screen_name
      end
      join_members(new_users)
    end

    Termtter::Client.register_command(
      :name => :collect_friends,
      :help => 'Collect friends for IRC.',
      :exec => lambda {|arg|
        sync_friends
      })

    Termtter::Client.register_hook(:collect_commands_for_irc_gw, :point => :post_command) do |text|
      sync_commands if text =~ /plug/
    end
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
    return unless Termtter::Client.find_command(termtter_command)
    post '#termtter', NOTICE, main_channel, '> ' + termtter_command
    Termtter::Client.execute(termtter_command)
  rescue Exception => e
    post '#termtter', NOTICE, main_channel, "#{e.class.to_s}: #{e.message}"
    Termtter::Client.handle_error(e)
  end

  def on_user(m)
    super
    @user = m.params.first
    post @prefix, JOIN, main_channel
    post server_name, MODE, main_channel, "+o", @prefix.nick
    sync_commands
    self.call(@@last_statuses || [], :update_friends_timeline)
  end

  def on_privmsg(m)
    target, message = *m.params
    if message =~ / +\//
      termtter_command = message.gsub(/ +\//, '')
      return unless Termtter::Client.find_command(termtter_command)
      post '#termtter', NOTICE, main_channel, '> ' + termtter_command
      Termtter::Client.execute(termtter_command)
      return
    end
    config.plugins.irc_gw.command_regexps and
    config.plugins.irc_gw.command_regexps.each do |rule|
      if message =~ rule
        command = message.scan(rule).first.join(' ')
        next unless Termtter::Client.find_command(command)
        post '#termtter', NOTICE, main_channel, '> ' + command
        Termtter::Client.execute(command)
        return
      end
    end
    Termtter::Client.execute('update ' + message)
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

  def sync_friends
    previous_friends = @friends
    new_friends = Termtter::Client.following_friends
    diff = new_friends - previous_friends
    join_members(diff)
    @friends += diff
  end

  def sync_commands
    previous_commands = @commands
    new_commands = Termtter::Client.commands.keys.map{|s| s.to_s.split(' ')}.flatten.uniq
    join_members(new_commands - previous_commands)
    @commands = new_commands
  end

  def join_members(members)
    params = []
    max_params_count = 3
    members.each do |member|
      prefix = Prefix.new("#{member}!#{member}@localhost")
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
