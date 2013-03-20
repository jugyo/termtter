# -*- coding: utf-8 -*-

require 'erb'
require 'set'

config.plugins.standard.set_default(
 :limit_format,
 '<<%=remaining_color%>><%=limit.remaining_hits%></<%=remaining_color%>>/<%=limit.hourly_limit%> until <%=Time.parse(limit.reset_time).getlocal%> (<%=remaining_time%> remaining)')

config.set_default(:easy_reply, false)
config.plugins.standard.set_default(
  :one_line_profile_format,
  '<90>[<%=user_id%>]</90> <%= mark %> <<%=color%>><%= user.screen_name %>: <%= padding %><%= (user.description || "").gsub(/\r?\n/, "") %></<%=color%>>')

module Termtter::Client
  register_command(
    :name => :reload,
    :exec => lambda {|arg|
      # NOTE: If edit this command, please check and edit lib/plugins/channel.rb too, please.
      args = {:include_entities => 1}
      args[:since_id] = @since_id if @since_id
      statuses = Termtter::API.twitter.home_timeline(args)
      unless statuses.empty?
        Termtter::Client.clear_line
        @since_id = statuses[0].id
        output(statuses, Termtter::Event.new(:update_friends_timeline, :type => :main))
        Readline.refresh_line if arg =~ /\-r/
      end
    },
    :help => ['reload', 'Reload time line']
  )

  register_command(
    :name => :update, :alias => :u,
    :exec => lambda {|arg|
      return if arg.empty?
      params =
        if config.easy_reply && /^\s*(@\w+)/ =~ arg
          user_name = normalize_as_user_name($1)
          in_reply_to_status_id =
            Termtter::API.twitter.user(:screen_name => user_name).status.id rescue nil
          in_reply_to_status_id ?
            {:in_reply_to_status_id => in_reply_to_status_id} : {}
        else
          {}
        end

      # "u $aa msg" is likely to be a mistake of
      # "re $aa msg".
      if /^\s*\d+\s/ =~ arg
        case HighLine.new.ask("Does it mean `re[ply] #{arg}` [N/y]? ")
        when /^[yY]$/
          Termtter::Client.execute("re #{arg}")
          break
        when /^[nN]?$/
        else
          puts "Invalid answer. Please input [yYnN] or nothing."
          break
        end
      end

      result = Termtter::API.twitter.update(arg, params)

      if ! result[:error]
        puts "updated => #{result.text}"
      else
        puts TermColor.parse("<red>Failed to update :(</red>")
      end
    },
    :help => ["update,u TEXT", "Post a new message"]
  )

  register_command(
    :name => :delete, :aliases =>[:del],
    :exec_proc => lambda {|arg|
      id =
        case arg
        when ''
          Termtter::API.twitter.user_timeline(:screen_name => config.user_name)[0].id
        when /^\d+$/
          arg.to_i
        end
      if id
        result = Termtter::API.twitter.remove_status(id)
        puts "deleted => #{result.text}"
      end
    },
    :help => ['delete,del [STATUS ID]', 'Delete a status']
  )

  unless defined? DirectMessage
    class DirectMessage < Struct.new(:id, :text, :user, :created_at)
      def method_missing(*args, &block)
        nil
      end
    end
  end

  register_command(
    :direct, :alias => :d,
    :help => ["direct,d USERNAME TEXT", "Send direct message"]) do |arg|
    if /^([^\s]+)\s+?(.*)\s*$/ =~ arg
      user, text = normalize_as_user_name($1), $2
      Termtter::API.twitter.direct_message(user, text)
      puts "=> to:#{user} message:#{text}"
    end
  end

  register_command(
    'direct list', :help => ["direct list", 'List direct messages']) do |arg|
    output(
      Termtter::API.twitter.direct_messages.map { |d|
        DirectMessage.new(d.id, "#{d.text} => #{d.recipient_screen_name}", d.sender, d.created_at)
      },
      Termtter::Event.new(
        :direct_messages,
        :type => :direct_message)
    )
  end

  register_command(
    'direct sent_list',
    :help => ["direct sent_list", 'List sent direct messages']) do |arg|
    output(
      Termtter::API.twitter.sent_direct_messages.map { |d|
      DirectMessage.new(
        d.id, "#{d.text} => #{d.recipient_screen_name}", d.sender, d.created_at)
      },
      Termtter::Event.new(
        :direct_messages,
        :type => :direct_message)
    )
  end

  def self.get_friends(user_name, max)
    self.get_friends_or_followers(:friends, user_name, max)
  end

  def self.get_followers(user_name, max)
    self.get_friends_or_followers(:followers, user_name, max)
  end

  def self.get_friends_or_followers(type, user_name, max)
    raise "type should be :friends or :followers" unless [:friends, :followers].include? type
    users = []
    cursor = -1
    begin
      tmp = Termtter::API::twitter.__send__(type, user_name, :cursor => cursor)
      cursor = tmp[:next_cursor]
      users += tmp[:users]
      puts "#{users.length}/#{max}" if max > 100
    rescue
      break
    end until (cursor.zero? or users.length > max)
    users.take(max)
  end

  register_command(
    :name => :friends, :aliases => [:following],
    :exec_proc => lambda {|arg|
      friends_or_followers_command(:friends, arg)
    },
    :help => ["friends [USERNAME] [-COUNT]", "Show user's friends."]
  )

  register_command(
    :name => :followers,
    :exec_proc => lambda {|arg|
      friends_or_followers_command(:followers, arg)
    },
    :help => ["followers [USERNAME]", "Show user's followers."]
  )

  def self.friends_or_followers_command(type, arg)
    raise "type should be :friends or :followers" unless [:friends, :followers].include? type
    limit = 20
    if /\-([\d]+)/ =~ arg
      limit = $1.to_i
      arg = arg.gsub(/\-([\d]+)/, '')
    end
    arg.strip!
    user_name = arg.empty? ? config.user_name : arg
    users = get_friends_or_followers(type, user_name, limit)
    longest = users.map{ |u| u.screen_name.length}.max
    users.reverse.each{|user|
      padding = ' ' * (longest - user.screen_name.length)
      user_id = Termtter::Client.data_to_typable_id(user.id) rescue ''
      color = user.following ? config.plugins.stdout.colors.first : config.plugins.stdout.colors.last
      mark  = user.following ? '♥' : '✂'
      erbed_text = ERB.new(config.plugins.standard.one_line_profile_format).result(binding)
      puts TermColor.unescape(TermColor.parse(erbed_text))
    }
  end

  class SearchEvent < Termtter::Event
    def initialize(query)
      super :search, {:query => query, :type => :search}
    end
  end
  public_storage[:search_keywords] = Set.new
  register_command(
    :name => :search, :aliases => [:s],
    :exec_proc => lambda {|arg|
      search_option = config.search.option.empty? ? {} : config.search.option
      statuses = Termtter::API.twitter.search(arg, search_option)
      public_storage[:search_keywords] << arg
      output(statuses, SearchEvent.new(arg))
    },
    :completion_proc => lambda {|cmd, arg|
      public_storage[:search_keywords].grep(/^#{Regexp.quote(arg)}/).map {|i| "#{cmd} #{i}" }
    },
    :help => ["search,s TEXT", "Search for Twitter"]
  )
  register_hook(:highlight_for_search_query, :point => :pre_coloring) do |text, event|
    case event
    when SearchEvent
      query = event.query.split(/\s/).map {|q|Regexp.quote(q)}.join("|")
      text.gsub(/#{query}/i, '<on_magenta><white>\0</white></on_magenta>')
    else
      text
    end
  end

  register_command(
    :name => :replies, :aliases => [:r],
    :exec_proc => lambda {|arg|
      if /\-([\d]+)/ =~ arg
        options = {:count => $1}
        arg = arg.gsub(/\-([\d]+)/, '')
      else
        options = {}
      end

      res = Termtter::API.twitter.mentions(options)
      unless arg.empty?
        res = res.select {|e| e.user.screen_name == arg }
      end
      output(res, Termtter::Event.new(:replies, :type => :reply))
    },
    :help => ["replies,r [username]", "List the replies (from the user)"]
  )

  register_command(
    :name => :show,
    :exec_proc => lambda {|arg|
      id = arg.gsub(/.*:\s*/, '')
      output([Termtter::API.twitter.show(id)], Termtter::Event.new(:show, :type => :show))
    },
    :completion_proc => lambda {|cmd, arg|
      case arg
      when /(\w+):\s*(\d+)\s*$/
        find_status_ids($2).map {|id| "#{cmd} #{$1}: #{id}"}
      else
        users = find_users(arg)
        unless users.empty?
          users.map {|user| "#{cmd} #{user}:"}
        else
          find_status_ids(arg).map {|id| "#{cmd} #{id}"}
        end
      end
    },
    :help => ["show ID", "Show a single status"]
  )

  register_command(
    :name => :shows,
    :exec_proc => lambda {|arg|
      id = arg.gsub(/.*:\s*/, '')
      # TODO: Implement
      #output([Termtter::API.twitter.show(id)], :show)
      puts "Not implemented yet."
    },
    :completion_proc => get_command(:show).completion_proc
  )

  register_command(
    :name => :follow, :aliases => [],
    :exec_proc => lambda {|args|
      args.split(' ').each do |arg|
        user_name = normalize_as_user_name(arg)
        user = Termtter::API::twitter.follow(:screen_name => user_name)
        puts "followed #{user.screen_name}"
      end
    },
    :help => ['follow USER', 'Follow user']
  )

  register_command(
    :name => :leave, :aliases => [:remove],
    :exec_proc => lambda {|args|
      args.split(' ').each do |arg|
        user_name = normalize_as_user_name(arg)
        user = Termtter::API::twitter.leave(:screen_name => user_name)
        puts "left #{user.screen_name}"
      end
    },
    :help => ['leave USER', 'Leave user']
  )

  register_command(
    :name => :block, :aliases => [],
    :exec_proc => lambda {|args|
      args.split(' ').each do |arg|
        user_name = normalize_as_user_name(arg)
        user = Termtter::API::twitter.block(:screen_name => user_name)
        puts "blocked #{user.screen_name}"
      end
    },
    :help => ['block USER', 'Block user']
  )

  register_command(
    :name => :unblock, :aliases => [],
    :exec_proc => lambda {|args|
      args.split(' ').each do |arg|
        user_name = normalize_as_user_name(arg)
        user = Termtter::API::twitter.unblock(:screen_name => user_name)
        puts "unblocked #{user.screen_name}"
      end
    },
    :help => ['unblock USER', 'Unblock user']
  )

  help = ['favorites,favlist USERNAME', 'show user favorites']
  register_command(:favorites, :alias => :favlist, :help => help) do |arg|
    output(Termtter::API.twitter.favorites(:screen_name => arg), Termtter::Event.new(:user_timeline, :type => :favorite))
  end

  register_command(
    :name => :favorite, :aliases => [:fav],
    :exec_proc => lambda {|args|
      args.split(' ').each do |arg|
        id =
          case arg
          when /^\d+/
            arg.to_i
          when /^@([A-Za-z0-9_]+)/
            user_name = normalize_as_user_name($1)
            statuses = Termtter::API.twitter.user_timeline(:screen_name => user_name)
            return if statuses.empty?
            statuses[0].id
          when %r{twitter.com/(?:\#!/)[A-Za-z0-9_]+/status(?:es)?/\d+}
            status_id = URI.parse(arg).path.split(%{/}).last
          when %r{twitter.com/[A-Za-z0-9_]+}
            user_name = normalize_as_user_name(URI.parse(arg).path.split(%{/}).last)
            statuses = Termtter::API.twitter.user_timeline(:screen_name => user_name)
            return if statuses.empty?
            statuses[0].id
          when /^\/(.*)$/
            word = $1
            raise "Not implemented yet."
          else
            if public_storage[:typable_id] && typable_id?(arg)
              typable_id_convert(arg)
            else
              return
            end
          end
        begin
          r = Termtter::API.twitter.favorite(:id => id)
          puts "Favorited status ##{r.id} on user @#{r.user.screen_name} #{r.text}"
        rescue => e
          handle_error e
        end
      end
    },
    :completion_proc => lambda {|cmd, arg|
      case arg
      when /(\d+)/
        find_status_ids(arg).map {|id| "#{cmd} #{id}"}
      else
        if data = Termtter::Client.typable_id_to_data(arg)
          "#{cmd} #{data}"
        else
          %w(favorite).grep(/^#{Regexp.quote arg}/)
        end
      end
    },
    :help => ['favorite,fav (ID|@USER|TYPABLE|/WORD)', 'Mark a status as a favorite']
  )

  def self.show_settings(conf, level = 0)
    conf.__values__.each do |k, v|
      if v.instance_of? Termtter::Config
        puts "#{k}:"
        show_settings v, level + 1
      else
        print '  ' * level
        puts "#{k} = #{v.nil? ? 'nil' : v.inspect}"
      end
    end
  end

  register_command(
    :name => :settings, :aliases => [:set],
    :exec_proc => lambda {|_|
      show_settings config
    },
    :help => ['settings,set', 'Show your settings']
  )

  # TODO: Change colors when remaining_hits is low.
  # TODO: Simmulate remaining_hits.
  register_command(
    :name => :limit, :aliases => [:lm],
    :exec_proc => lambda {|arg|
      limit = Termtter::API.twitter.limit_status
      remaining_time = "%dmin %dsec" % (Time.parse(limit.reset_time) - Time.now).divmod(60)
      remaining_color =
        case limit.remaining_hits / limit.hourly_limit.to_f
        when 0.2..0.4 then :yellow
        when 0..0.2   then :red
        else               :green
        end
      erbed_text = ERB.new(config.plugins.standard.limit_format).result(binding)
      puts TermColor.parse(erbed_text)
    },
    :help => ["limit,lm", "Show the API limit status"]
  )

  register_command(
    :name => :pause,
    :exec_proc => lambda {|arg| pause},
    :help => ["pause", "Pause updating"]
  )

  register_command(
    :name => :resume,
    :exec_proc => lambda {|arg| resume},
    :help => ["resume", "Resume updating"]
  )

  register_command(
    :name => :exit, :aliases => [:quit],
    :exec_proc => lambda {|arg| exit},
    :help => ['exit,quit', 'Exit']
  )

  register_command(
    :name => :help, :aliases => [:h],
    :exec_proc => lambda {|arg|
      helps = []
      @commands.map do |name, command|
        next unless command.help
        case command.help[0]
        when String
          helps << command.help
        when Array
          helps += command.help
        end
      end
      helps.compact!
      unless arg.empty?
        helps = helps.select {|n, _| /#{arg}/ =~ n }
      end
      puts formatted_help(helps)
    },
    :help => ["help,h", "Print this help message"]
  )

  def self.formatted_help(helps)
    helps = helps.sort_by {|help| help[0] }
    width = helps.map {|n, _| n.size }.max
    space = 3
    helps.map {|name, desc|
      name.to_s.ljust(width + space) + desc.to_s
    }.join("\n")
  end

  register_command(
    :name      => :plug,
    :alias     => :plugin,
    :exec_proc => lambda {|arg|
      if arg.empty?
        puts plugin_list.join(', ')
        return
      end
      begin
        result = plug arg
      rescue LoadError
      ensure
        puts "=> #{result.inspect}"
      end
    },
    :completion_proc => lambda {|cmd, args|
      plugin_list.grep(/#{Regexp.quote(args)}/).map {|i| "#{cmd} #{i}"}
    },
    :help => ['plug FILE', 'Load a plugin']
  )

  ## plugin_list :: IO ()
  def self.plugin_list
    (Dir["#{File.dirname(__FILE__)}/../**/*.rb"] + Dir["#{Termtter::CONF_DIR}/plugins/**/*.rb"]).
      map {|f| File.expand_path(f).scan(/.*plugins\/(.*)\.rb/).flatten[0] }.
      sort
  end

  register_command(
    :name => :reply,
    :aliases => [:re],
    :exec_proc => lambda {|arg|
      case arg
      when /^\s*(?:list|ls)\s*(?:\s+(\w+))?\s*$/
        public_storage[:log4re] =
          if $1
            public_storage[:log].
              select {|l| l.user.screen_name == $1}.
              sort {|a,b| a.id <=> b.id}
          else
            public_storage[:log].sort {|a,b| a.id <=> b.id}
          end
        public_storage[:log4re].each_with_index do |s, i|
          puts "#{i}: #{s.user.screen_name}: #{s.text}"
        end
      when /^\s*(?:up(?:date)?)\s+(\d+)\s+(.+)$/
        id   = public_storage[:log4re][$1.to_i].id
        text = $2
        user = public_storage[:log4re][$1.to_i].user
        update_with_user_and_id(text, user.screen_name, id) if user
        public_storage.delete :log4re
      when /^\s*(\d+)\s+(.+)$/
        s = Termtter::API.twitter.show($1) rescue nil
        if s
          update_with_user_and_id($2, s.user.screen_name, s.id)
        end
      when /^\s*(@\w+)/
        user_name = normalize_as_user_name($1)
        s = Termtter::API.twitter.user(:screen_name => user_name).status
        if s
          params = s ? {:in_reply_to_status_id => s.id} : {}
          Termtter::API.twitter.update(arg, params)
          puts "=> #{arg}"
        end
      else
        text = arg
        last_reply = Termtter::API.twitter.replies({:count => 1}).first
        update_with_user_and_id(text, last_reply.user.screen_name, last_reply.id)
      end
    },
    :completion_proc => lambda {|cmd, arg|
      case arg
      when /(\d+)/
        find_status_ids(arg).map {|id| "#{cmd} #{id}"}
      end
    },
    :help => ["reply,re @USERNAME or STATUS_ID", "Send a reply"]
  )

  register_command(
    :name => :redo,
    :aliases => [:"."],
    :exec_proc => lambda {|arg|
      break if Readline::HISTORY.length < 2
      i = Readline::HISTORY.length - 2
      input = ""
      begin
        input = Readline::HISTORY[i]
        i -= 1
        return if i <= 0
      end while input == "redo" or input == "."
      begin
        Termtter::Client.execute(input)
      rescue CommandNotFound => e
        warn "Unknown command \"#{e}\""
        warn 'Enter "help" for instructions'
      rescue => e
        handle_error e
      end
    },
    :help => ["redo,.", "Execute previous command"]
  )

  class << self
    def update_with_user_and_id(text, username, id)
      text = "@#{username} #{text}"
      result = Termtter::API.twitter.update(text, {'in_reply_to_status_id' => id })
      puts "replied => #{result.text}"
    end

    def normalize_as_user_name(text)
      text.strip.sub(/^@/, '')
    end

    def find_status_ids(text)
      public_storage[:status_ids].select {|id| /#{Regexp.quote(text)}/ =~ id.to_s }
    end

    def find_users(text)
      public_storage[:users].select {|user| /^#{Regexp.quote(text)}/ =~ user }
    end
  end
end
