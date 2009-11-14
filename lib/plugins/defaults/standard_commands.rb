# -*- coding: utf-8 -*-

require 'erb'
require 'set'

config.plugins.standard.set_default(
 :limit_format,
 '<<%=remaining_color%>><%=limit.remaining_hits%></<%=remaining_color%>>/<%=limit.hourly_limit%> until <%=Time.parse(limit.reset_time).getlocal%> (<%=remaining_time%> remaining)')

config.set_default(:easy_reply, true)

module Termtter::Client

  register_command(
    :name => :reload,
    :exec => lambda {|arg|
      args = @since_id ? [{:since_id => @since_id}] : []
      statuses = Termtter::API.twitter.friends_timeline(*args)
      unless statuses.empty?
        print "\e[0G" + "\e[K" unless win?
        @since_id = statuses[0].id
        output(statuses, :update_friends_timeline)
        Readline.refresh_line if arg =~ /\-r/
      end
    }
  )

  register_command(
    :name => :update, :alias => :u,
    :exec => lambda {|arg|
      unless arg.rstrip.empty?
        params =
          if config.easy_reply && /^\s*(@\w+)/ =~ arg
            user_name = normalize_as_user_name($1)
            in_reply_to_status_id = Termtter::API.twitter.user(user_name).status.id rescue nil
            in_reply_to_status_id ? {:in_reply_to_status_id => in_reply_to_status_id} : {}
          else
            {}
          end

        result = Termtter::API.twitter.update(arg, params)
        puts "updated => #{result.text}"
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
          Termtter::API.twitter.user_timeline(config.user_name)[0].id
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

  direct_message_struct = Struct.new(:id, :text, :user, :created_at)
  direct_message_struct.class_eval do
    def method_missing(*args, &block)
      nil
    end
  end
  register_command(
    :name => :direct, :aliases => [:d],
    :exec_proc => lambda {|arg|
      case arg
      when /^([^\s]+)\s+?(.*)\s*$/
        user, text = normalize_as_user_name($1), $2
        Termtter::API.twitter.direct_message(user, text)
        puts "=> to:#{user} message:#{text}"
      when 'list'
        output(
          Termtter::API.twitter.direct_messages.map { |d|
            direct_message_struct.new(d.id, "#{d.text} => #{d.recipient_screen_name}", d.sender, d.created_at)
          },
          :direct_messages
        )
      when 'sent_list'
        output(
          Termtter::API.twitter.sent_direct_messages.map { |d|
            direct_message_struct.new(d.id, "#{d.text} => #{d.recipient_screen_name}", d.sender, d.created_at)
          },
          :direct_messages
        )
      end
    },
    :help => [
      ["direct,d USERNAME TEXT", "Send direct message"],
      ["direct,d list", 'List direct messages'],
      ["direct,d sent_list", 'List sent direct messages']
    ]
  )

  register_command(
    :name => :profile, :aliases => [:p],
    :exec_proc => lambda {|arg|
      user_name = arg.empty? ? config.user_name : arg
      user = Termtter::API.twitter.user(user_name)
      attrs = %w[ name screen_name url description profile_image_url location protected following
        friends_count followers_count statuses_count favourites_count
        id time_zone created_at utc_offset notifications
      ]
      label_width = attrs.map(&:size).max
      attrs.each do |attr|
        value = user.__send__(attr.to_sym)
        puts "#{attr.gsub('_', ' ').rjust(label_width)}: #{value}"
      end
    },
    :help => ["profile,p [USERNAME]", "Show user's profile."]
  )

  register_command(
    :name => :followers,
    :exec_proc => lambda {|arg|
      user_name = normalize_as_user_name(arg)
      user_name = config.user_name if user_name.empty?

      followers = []
      page = 0
      begin
        followers += tmp = Termtter::API.twitter.followers(user_name, :page => page+=1)
      end until tmp.empty?
      Termtter::Client.public_storage[:followers] = followers
      public_storage[:users] += followers.map(&:screen_name)
      puts followers.map(&:screen_name).join(' ')
    },
    :help => ["followers", "Show followers"]
  )

  register_command(
    :name => :list, :aliases => [:l],
    :exec_proc => lambda {|arg|
      if arg =~ /\-([\d]+)/
        options = {:count => $1}
        arg = arg.gsub(/\-([\d]+)/, '')
      else
        options = {}
      end

      if arg.empty?
        event = :list_friends_timeline
        statuses = Termtter::API.twitter.friends_timeline(options)
      else
        event = :list_user_timeline
        statuses = []
        Array(arg.split).each do |user|
          user_name = normalize_as_user_name(user)
          statuses += Termtter::API.twitter.user_timeline(user_name, options)
        end
      end
      output(statuses, event)
    },
    :help => ["list,l [USERNAME] [-COUNT]", "List the posts"]
  )

  class SearchEvent; attr_reader :query; def initialize(query); @query = query end; end
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
      public_storage[:search_keywords].grep(/^#{Regexp.quote(arg)}/).map { |i| "#{cmd} #{i}" }
    },
    :help => ["search,s TEXT", "Search for Twitter"]
  )
  register_hook(:highlight_for_search_query, :point => :pre_coloring) do |text, event|
    case event
    when SearchEvent
      query = event.query.split(/\s/).map {|q|Regexp.quote(q)}.join("|")
      text.gsub(/(#{query})/i, '<on_magenta><white>\1</white></on_magenta>')
    else
      text
    end
  end

  register_command(
    :name => :replies, :aliases => [:r],
    :exec_proc => lambda {|arg|
      res = Termtter::API.twitter.replies
      unless arg.empty?
        res = res.map {|e| e.user.screen_name == arg ? e : nil }.compact
      end
      output(res, :replies)
    },
    :help => ["replies,r", "List the replies"]
  )

  register_command(
    :name => :show,
    :exec_proc => lambda {|arg|
      id = arg.gsub(/.*:\s*/, '')
      output([Termtter::API.twitter.show(id)], :show)
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
        res = Termtter::API::twitter.follow(user_name)
      end
    },
    :help => ['follow USER', 'Follow user']
  )

  register_command(
    :name => :leave, :aliases => [],
    :exec_proc => lambda {|args|
      args.split(' ').each do |arg|
        user_name = normalize_as_user_name(arg)
        res = Termtter::API::twitter.leave(user_name)
      end
    },
    :help => ['leave USER', 'Leave user']
  )

  register_command(
    :name => :favorite, :aliases => [:fav],
    :exec_proc => lambda {|arg|
      id =
        case arg
        when /^\d+/
          arg.to_i
        when /^@([A-Za-z0-9_]+)/
          user_name = normalize_as_user_name($1)
          statuses = Termtter::API.twitter.user_timeline(user_name)
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

      r = Termtter::API.twitter.favorite id
      puts "Favorited status ##{r.id} on user @#{r.user.screen_name} #{r.text}"
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
        plugin_list
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
      plugin_list.grep(/^#{Regexp.quote(args)}/).map {|i| "#{cmd} #{i}"}
    },
    :help => ['plug FILE', 'Load a plugin']
  )

  ## plugin_list :: IO ()
  def self.plugin_list
    (Dir["#{File.dirname(__FILE__)}/../*.rb"] + Dir["#{Termtter::CONF_DIR}/plugins/*.rb"]).
      map {|f| File.basename(f).sub(/\.rb$/, '')}.
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
        s = Termtter::API.twitter.user(user_name).status
        if s
          params = s ? {:in_reply_to_status_id => s.id} : {}
          Termtter::API.twitter.update(arg, params)
          puts "=> #{arg}"
        end
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
        Termtter::Client.call_commands(input)
      rescue CommandNotFound => e
        warn "Unknown command \"#{e}\""
        warn 'Enter "help" for instructions'
      rescue => e
        handle_error e
      end
    },
    :help => ["redo,.", "Execute previous command"]
  )

  def self.update_with_user_and_id(text, username, id)
    text = "@#{username} #{text}"
    result = Termtter::API.twitter.update(text, {'in_reply_to_status_id' => id})
    puts "replied => #{result.text}"
  end

  def self.normalize_as_user_name(text)
    text.strip.sub(/^@/, '')
  end

  def self.find_status_ids(text)
    public_storage[:status_ids].select {|id| /#{Regexp.quote(text)}/ =~ id.to_s}
  end

  def self.find_users(text)
    public_storage[:users].select {|user| /^#{Regexp.quote(text)}/ =~ user}
  end
end
