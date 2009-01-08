$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'json'
require 'net/https'
require 'open-uri'
require 'cgi'
require 'readline'
require 'enumerator'
require 'parsedate'
require 'configatron'

if RUBY_VERSION < '1.8.7'
  class Array
    def take(n) self[0...n] end
  end
end

def win?
  RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|bccwin/
end

if win?
  require 'kconv'
  module Readline
    alias :old_readline :readline
    def readline(*a)
      old_readline(*a).toutf8
    end
    module_function :old_readline, :readline
  end
end

configatron.set_default(:update_interval, 300)
configatron.set_default(:prompt, '> ')
configatron.set_default(:enable_ssl, false)
configatron.proxy.set_default(:port, '8080')

# FIXME: we need public_storage all around the script
module Termtter
  module Client
    def self.public_storage
      @@public_storage ||= {}
    end
  end
end

def plugin(s)
  require "plugin/#{s}"
end

def filter(s)
  load "filter/#{s}.rb"
rescue LoadError
  raise
else
  Termtter::Client.public_storage[:filters] = []
  Termtter::Client.public_storage[:filters] << s
  true
end

# FIXME: delete this method after the major version up
unless defined? original_require
  alias original_require require
  def require(s)
    if %r|^termtter/(.*)| =~ s
      puts "[WARNING] use plugin '#{$1}' instead of require"
      puts "  Such a legacy .termtter file will not be supported until version 1.0.0"
      s = "plugin/#{$1}"
    end
    original_require s
  end
end

module Termtter
  VERSION = '0.7.0'
  APP_NAME = 'termtter'

  class Connection
    attr_reader :protocol, :port, :proxy_uri

    def initialize
      @proxy_host = configatron.proxy.host
      @proxy_port = configatron.proxy.port
      @proxy_user = configatron.proxy.user_name
      @proxy_password = configatron.proxy.password
      @proxy_uri = nil
      @enable_ssl = configatron.enable_ssl
      @protocol = "http"
      @port = 80

      unless @proxy_host.empty?
        @http_class = Net::HTTP::Proxy(@proxy_host, @proxy_port,
                                       @proxy_user, @proxy_password)
        @proxy_uri =  "http://" + @proxy_host + ":" + @proxy_port + "/"
      else
        @http_class = Net::HTTP
      end

      if @enable_ssl
        @protocol = "https"
        @port = 443
      end
    end

    def start(host, port, &block)
      http = @http_class.new(host, port)
      http.use_ssl = @enable_ssl
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http.use_ssl
      http.start(&block)
    end
  end

  class Twitter

    def initialize(user_name, password)
      @user_name = user_name
      @password = password
      @connection = Connection.new
    end

    def update_status(status)
      @connection.start("twitter.com", @connection.port) do |http|
        uri = '/statuses/update.xml'
        http.request(post_request(uri), "status=#{CGI.escape(status)}&source=#{APP_NAME}")
      end
      status
    end

    def get_friends_timeline(since_id = nil)
      uri =  "#{@connection.protocol}://twitter.com/statuses/friends_timeline.json"
      uri << "?since_id=#{since_id}" if since_id
      return get_timeline(uri)
    end

    def get_user_timeline(screen_name)
      return get_timeline("#{@connection.protocol}://twitter.com/statuses/user_timeline/#{screen_name}.json")
    rescue OpenURI::HTTPError => e
      puts "No such user: #{screen_name}"
      nears = near_users(screen_name)
      puts "near users: #{nears}" unless nears.empty?
      return {}
    end

    def search(query)
      results = JSON.parse(open("#{@connection.protocol}://search.twitter.com/search.json?q=" + CGI.escape(query)).read, :proxy => @connection.proxy_uri)['results']
      return results.map do |s|
        status = Status.new
        status.id = s['id']
        status.text = CGI.unescapeHTML(s['text']).gsub(/(\n|\r)/, '')
        status.created_at = Time.utc(*ParseDate::parsedate(s["created_at"])).localtime
        status.user_screen_name = s['from_user']
        status
      end
    end

    def show(id)
      return get_timeline("#{@connection.protocol}://twitter.com/statuses/show/#{id}.json")
    end

    def replies
      return get_timeline("#{@connection.protocol}://twitter.com/statuses/replies.json")
    end

    def get_timeline(uri)
      data = JSON.parse(open(uri, :http_basic_authentication => [user_name, password], :proxy => @connection.proxy_uri).read)
      data = [data] unless data.instance_of? Array
      return data.map do |s|
        status = Status.new
        status.created_at = Time.utc(*ParseDate::parsedate(s["created_at"])).localtime
        %w(id text truncated in_reply_to_status_id in_reply_to_user_id).each do |key|
          status.__send__("#{key}=".to_sym, s[key])
        end
        %w(id name screen_name url profile_image_url).each do |key|
          status.__send__("user_#{key}=".to_sym, s["user"][key])
        end
        status.text = CGI.unescapeHTML(status.text).gsub(/(\n|\r)/, '')
        status
      end
    end

    # note: APILimit.reset_time_in_seconds == APILimit.reset_time.to_i
    APILIMIT = Struct.new("APILimit", :reset_time, :reset_time_in_seconds, :remaining_hits, :hourly_limit)
    def get_rate_limit_status
      uri = 'http://twitter.com/account/rate_limit_status.json'
      data = JSON.parse(open(uri, :http_basic_authentication => [user_name, password], :proxy => @connection.proxy_uri).read)

      reset_time = Time.parse(data['reset_time'])
      reset_time_in_seconds = data['reset_time_in_seconds'].to_i
      
      APILIMIT.new(reset_time, reset_time_in_seconds, data['remaining_hits'], data['hourly_limit'])
    end

    alias :api_limit :get_rate_limit_status

    private

    def user_name
      unless @user_name.instance_of? String
        @user_name = Readline.readline('user name: ', false)
      end
      @user_name
    end

    def password
      unless @password.instance_of? String
        system 'stty -echo'
        @password = Readline.readline('password: ', false)
        system 'stty echo'
        puts
      end
      @password
    end

    def near_users(screen_name)
      Client::public_storage[:users].select {|user|
        /#{user}/i =~ screen_name || /#{screen_name}/i =~ user
      }.join(', ')
    end

    def post_request(uri)
      req = Net::HTTP::Post.new(uri)
      req.basic_auth(user_name, password)
      req.add_field('User-Agent', 'Termtter http://github.com/jugyo/termtter')
      req.add_field('X-Twitter-Client', 'Termtter')
      req.add_field('X-Twitter-Client-URL', 'http://github.com/jugyo/termtter')
      req.add_field('X-Twitter-Client-Version', '0.1')
      req
    end
  end

  module Client

    @@hooks = []
    @@commands = {}
    @@completions = []
    @@filters = []
    @@helps = []

    class << self
      def add_hook(&hook)
        @@hooks << hook
      end

      def clear_hooks
        @@hooks.clear
      end

      def add_command(regex, &block)
        @@commands[regex] = block
      end

      def add_macro(r, s)
        add_command(r) do |m, t|
          call_commands(s % m, t)
        end
      end

      def clear_commands
        @@commands.clear
      end

      def add_completion(&completion)
        @@completions << completion
      end

      def clear_completions
        @@completions.clear
      end

      def add_help(name, desc)
        @@helps << [name, desc]
      end

      def clear_helps
        @@helps.clear
      end

      def add_filter(&filter)
        @@filters << filter
      end

      def clear_filters
        @@filters.clear
      end

      # memo: each filter must return Array of Status
      def apply_filters(statuses)
        filtered = statuses
        @@filters.each do |f|
          filtered = f.call(filtered)
        end
        filtered
      rescue => e
        puts "Error: #{e}"
        puts e.backtrace.join("\n")
        statuses
      end

      Readline.basic_word_break_characters= "\t\n\"\\'`><=;|&{("
      Readline.completion_proc = proc {|input|
        @@completions.map {|completion|
          completion.call(input)
        }.flatten.compact
      }

      def call_hooks(statuses, event, tw)
        statuses = apply_filters(statuses)
        @@hooks.each do |h|
          begin
            h.call(statuses.dup, event, tw)
          rescue => e
            puts "Error: #{e}"
            puts e.backtrace.join("\n")
          end
        end
      end

      def call_commands(text, tw)
        return if text.empty?

        command_found = false
        @@commands.each do |key, command|
          if key =~ text
            command_found = true
            begin
              command.call($~, tw)
            rescue => e
              puts "Error: #{e}"
              puts e.backtrace.join("\n")
            end
          end
        end

        raise CommandNotFound unless command_found
      end

      def pause
        @@pause = true
      end

      def resume
        @@pause = false
        @@update_thread.run
      end

      def exit
        call_hooks([], :exit, nil)
        @@main_thread.kill
        @@update_thread.kill
        @@input_thread.kill
      end

      def run
        puts 'initializing...'
        initialized = false
        @@pause = false
        tw = Termtter::Twitter.new(configatron.user_name, configatron.password)
        call_hooks([], :initialize, tw)

        @@input_thread = nil
        @@update_thread = Thread.new do
          since_id = nil
          loop do
            begin
              Thread.stop if @@pause

              statuses = tw.get_friends_timeline(since_id)
              unless statuses.empty?
                since_id = statuses[0].id
              end
              print "\e[1K\e[0G" if !statuses.empty? && !win?
              call_hooks(statuses, :update_friends_timeline, tw)
              initialized = true
              @@input_thread.kill if @@input_thread && !statuses.empty?
            rescue OpenURI::HTTPError => e
              if e.message == '401 Unauthorized'
                puts 'Could not login'
                puts 'plese check your account settings'
                exit!
              end
            rescue => e
              puts "Error: #{e}"
              puts e.backtrace.join("\n")
            ensure
              sleep configatron.update_interval
            end
          end
        end

        until initialized; end

        vi_or_emacs = configatron.editing_mode
        unless vi_or_emacs.empty?
          Readline.__send__("#{vi_or_emacs}_editing_mode")
        end

        begin
          stty_save = `stty -g`.chomp
          trap("INT") { system "stty", stty_save; exit }
        rescue Errno::ENOENT
        end

        @@main_thread = Thread.new do
          loop do
            @@input_thread = create_input_thread(tw)
            @@input_thread.join
          end
        end
        @@main_thread.join
      end

      def create_input_thread(tw)
        Thread.new do
          erb = ERB.new(configatron.prompt)
          while buf = Readline.readline(erb.result(tw.__send__(:binding)), true)
            begin
              call_commands(buf, tw)
            rescue CommandNotFound => e
              puts "Unknown command \"#{buf}\""
              puts 'Enter "help" for instructions'
            rescue => e
              puts "Error: #{e}"
              puts e.backtrace.join("\n")
            end
          end
        end
      end
    end
  end

  class CommandNotFound < StandardError; end

  class Status
    %w(
      id text created_at truncated in_reply_to_status_id in_reply_to_user_id 
      user_id user_name user_screen_name user_url user_profile_image_url
    ).each do |attr|
      attr_accessor attr.to_sym
    end

    def english?
      self.class.english?(self.text)
    end

    # english? :: String -> Boolean
    def self.english?(message)
      /[一-龠]+|[ぁ-ん]+|[ァ-ヴー]+|[ａ-ｚＡ-Ｚ０-９]+/ !~ message
    end
  end
end

