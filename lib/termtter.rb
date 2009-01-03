require 'rubygems'
require 'json'
require 'open-uri'
require 'cgi'
require 'readline'
require 'enumerator'
require 'parsedate'

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module Termtter
  VERSION = '0.3.7'

  class CommandNotFound < StandardError; end

  class Client

    @@hooks = []
    @@commands = {}

    def self.add_hook(&hook)
      @@hooks << hook
    end

    def self.clear_hooks
      @@hooks.clear
    end

    def self.add_command(regex, &block)
      @@commands[regex] = block
    end

    def self.clear_commands
      @@commands.clear
    end

    attr_reader :since_id, :public_storage

    def initialize
      configatron.set_default(:update_interval, 300)
      configatron.set_default(:debug, false)
      @user_name = configatron.user_name
      @password = configatron.password
      @update_interval = configatron.update_interval
      @debug = configatron.debug
      @public_storage = {}
    end

    def update_status(status)
      req = Net::HTTP::Post.new('/statuses/update.xml')
      req.basic_auth(@user_name, @password)
      req.add_field("User-Agent", "Termtter http://github.com/jugyo/termtter")
      req.add_field("X-Twitter-Client", "Termtter")
      req.add_field("X-Twitter-Client-URL", "http://github.com/jugyo/termtter")
      req.add_field("X-Twitter-Client-Version", "0.1")
      Net::HTTP.start("twitter.com", 80) do |http|
        http.request(req, "status=#{CGI.escape(status)}")
      end
    end

    def list_friends_timeline
      statuses = get_timeline("http://twitter.com/statuses/friends_timeline.json")
      call_hooks(statuses, :list_friends_timeline)
    end

    def update_friends_timeline
      uri = "http://twitter.com/statuses/friends_timeline.json"
      if @since_id && !@since_id.empty?
        uri += "?since_id=#{@since_id}"
      end

      statuses = get_timeline(uri, true)
      call_hooks(statuses, :update_friends_timeline)
    end

    def get_user_timeline(screen_name)
      statuses = get_timeline("http://twitter.com/statuses/user_timeline/#{screen_name}.json")
      call_hooks(statuses, :list_user_timeline)
    end

    def search(query)
      statuses = []

      results = JSON.parse(open('http://search.twitter.com/search.json?q=' + CGI.escape(query)).read)['results']
      results.each do |s|
        status = Status.new
        status.text = s['text']
        status.created_at = Time.utc(*ParseDate::parsedate(s["created_at"])).localtime
        status.user_screen_name = s['from_user']
        statuses << status
      end

      call_hooks(statuses, :search)
      return statuses
    end

    def show(id)
      statuses = get_timeline("http://twitter.com/statuses/show/#{id}.json")
      call_hooks(statuses, :show)
    end

    def replies
      statuses = get_timeline("http://twitter.com/statuses/replies.json")
      call_hooks(statuses, :show)
    end

    def call_hooks(statuses, event)
      @@hooks.each do |h|
        begin
          h.call(statuses.dup, event, self)
        rescue => e
          puts "Error: #{e}"
          puts e.backtrace.join("\n")
        end
      end
    end

    def get_timeline(uri, update_since_id = false)
      statuses = []

      JSON.parse(open(uri, :http_basic_authentication => [@user_name, @password]).read).each do |s|
        u = s["user"]
        status = Status.new
        status.created_at = Time.utc(*ParseDate::parsedate(s["created_at"])).localtime
        %w(id text truncated in_reply_to_status_id in_reply_to_user_id).each do |key|
          status.send("#{key}=".to_sym, s[key])
        end
        %w(id name screen_name url profile_image_url).each do |key|
          status.send("user_#{key}=".to_sym, u[key])
        end
        statuses << status
      end

      if update_since_id && !statuses.empty?
        @since_id = statuses[0].id
      end

      return statuses
    end

    def call_commands(text)
      return if text.empty?

      command_found = false
      @@commands.each do |key, command|
        if key =~ text
          command_found = true
          begin
            command.call($~, self)
          rescue => e
            puts "Error: #{e}"
            puts e.backtrace.join("\n")
          end
        end
      end

      raise CommandNotFound unless command_found
    end

    def pause
      @pause = true
    end

    def resume
      @pause = false
      @update.run
    end

    def exit
      @update.kill
      @input.kill
    end

    def run
      @pause = false

      @update = Thread.new do
        loop do
          if @pause
            Thread.stop
          end
          update_friends_timeline()
          sleep @update_interval
        end
      end

      @input = Thread.new do
        while buf = Readline.readline("", true)
          begin
            call_commands(buf)
          rescue CommandNotFound => e
            puts "Unknown command \"#{buf}\""
            puts 'Enter "help" for instructions'
          rescue => e
            puts "Error: #{e}"
            puts e.backtrace.join("\n")
          end
        end
      end

      stty_save = `stty -g`.chomp
      trap("INT") { system "stty", stty_save; self.exit }

      @input.join
    end

  end

  class Status
    %w(
      id text created_at truncated in_reply_to_status_id in_reply_to_user_id 
      user_id user_name user_screen_name user_url user_profile_image_url
    ).each do |attr|
      attr_accessor attr.to_sym
    end
  end

end
