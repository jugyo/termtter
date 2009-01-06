require 'rubygems'
require 'json'
require 'open-uri'
require 'cgi'
require 'readline'
require 'enumerator'
require 'parsedate'
require 'configatron'

if RUBY_VERSION < '1.8.7'
  class Array
    def take(n) at(0...n) end
  end
end

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

configatron.set_default(:update_interval, 300)
configatron.set_default(:prompt, '> ')
configatron.set_default(:editing_mode, 'vi')

editing_mode = configatron.editing_mode
editing_mode = 'vi' unless %w[ vi emacs ].include? editing_mode
Readline.__send__("#{editing_mode}_editing_mode")

def plugin(s)
  require "plugin/#{s}"
end

# FIXME: delete this method after the major version up
alias original_require require
def require(s)
  if %r|^termtter/(.*)| =~ s
    puts "[WARNING] use plugin '#{$1}' instead of require"
    puts "  Such a legacy .termtter file will not be supported until version 1.0.0"
    s = "plugin/#{$1}"
  end
  original_require s
end

module Termtter
  VERSION = '0.5.8'

  class Twitter

    def initialize(user_name, password)
      @user_name = user_name
      @password = password
    end

    def update_status(status)
      Net::HTTP.start("twitter.com", 80) do |http|
        uri = '/statuses/update.xml'
        http.request(post_request(uri), "status=#{CGI.escape(status)}")
      end
    end

    def get_friends_timeline(since_id = nil)
      uri = "http://twitter.com/statuses/friends_timeline.json"
      uri << "?since_id=#{since_id}" if since_id
      return get_timeline(uri)
    end

    def get_user_timeline(screen_name)
      return get_timeline("http://twitter.com/statuses/user_timeline/#{screen_name}.json")
    rescue OpenURI::HTTPError => e
      puts "No such user: #{screen_name}"
      nears = near_users(screen_name)
      puts "near users: #{nears}" unless nears.empty?
      return {}
    end

    def search(query)
      results = JSON.parse(open('http://search.twitter.com/search.json?q=' + CGI.escape(query)).read)['results']
      return results.map do |s|
        status = Status.new
        status.id = s['id']
        status.text = s['text']
        status.created_at = Time.utc(*ParseDate::parsedate(s["created_at"])).localtime
        status.user_screen_name = s['from_user']
        status
      end
    end

    def show(id)
      return get_timeline("http://twitter.com/statuses/show/#{id}.json")
    end

    def replies
      return get_timeline("http://twitter.com/statuses/replies.json")
    end

    def get_timeline(uri)
      data = JSON.parse(open(uri, :http_basic_authentication => [@user_name, @password]).read)
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
        status.text = CGI.unescapeHTML(status.text)
        status
      end
    end

    def near_users(screen_name)
      Client::public_storage[:users].select {|user|
        /#{user}/i =~ screen_name || /#{screen_name}/i =~ user
      }.join(', ')
    end
    private :near_users

    def post_request(uri)
      req = Net::HTTP::Post.new(uri)
      req.basic_auth(@user_name, @password)
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

      Readline.basic_word_break_characters= "\t\n\"\\'`><=;|&{("
      Readline.completion_proc = proc {|input|
        @@completions.map {|completion|
          completion.call(input)
        }.flatten.compact
      }

      def public_storage
        @@public_storage ||= {}
      end

      def call_hooks(statuses, event, tw)
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
        @@update_thread.kill
        @@input_thread.kill
      end

      def run
        puts 'initializing...'
        initialized = false
        @@pause = false
        tw = Termtter::Twitter.new(configatron.user_name, configatron.password)

        @@update_thread = Thread.new do
          since_id = nil
          loop do
            begin
              Thread.stop if @@pause

              statuses = tw.get_friends_timeline(since_id)
              unless statuses.empty?
                since_id = statuses[0].id
              end
              call_hooks(statuses, :update_friends_timeline, tw)
              initialized = true

            rescue => e
              puts "Error: #{e}"
              puts e.backtrace.join("\n")
            ensure
              sleep configatron.update_interval
            end
          end
        end

        until initialized; end

        @@input_thread = Thread.new do
          while buf = Readline.readline(configatron.prompt, true)
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

        stty_save = `stty -g`.chomp
        trap("INT") { system "stty", stty_save; exit }

        @@input_thread.join
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
  end

end
