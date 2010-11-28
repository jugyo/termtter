config.plugins.channel.set_default(:auto_reload_channels,  {})
config.plugins.channel.set_default(:short_names,           {})
config.plugins.channel.set_default(:colorize,              true)
config.plugins.channel.set_default(:output_length,         7)
config.plugins.channel.set_default(:default_channel,       :main)
config.plugins.channel.set_default(:channel_to_hash_proc,  lambda {|c| c.to_i(36) })

# Channel spec
#   /^@(.+)/           -- user_timeline of $1
#   /^(.+)_s(earch)?$/ -- search result of $1
#   /^replies$/        -- replies
#   /^main$/           -- home_timeline
#   otherwise          -- list

# Extention Core
module Termtter
  module API
    class << self
      def call_by_channel(c, *opt)
        case c.to_s
        when "main"
          Termtter::API.twitter.home_timeline(*opt)
        when "replies"
          Termtter::API.twitter.replies(*opt)
        when /^(.+)_s(earch)?$/
          Termtter::API.twitter.search($1, *opt)
        else
          user_name, slug = c.to_s.split('/')
          if !user_name.nil? && slug.nil?
            slug = user_name
            user_name = config.user_name
          elsif user_name.empty?
            user_name = config.user_name
          end
          user_name = Termtter::Client.normalize_as_user_name(user_name)
          Termtter::API.twitter.list_statuses(user_name, slug, *opt)
        end
      end
    end
  end
end

now_channel = config.plugins.channel.default_channel

Termtter::Client.register_command(
  :name => :channel,
  :alias => :c,
  :help => ['channel, c', 'Show current channel or change channel'],
  :author => 'Sora Harakami',
  :exec => lambda {|arg|
    if arg.empty?
      puts "Current channel is #{now_channel}"
    else
      old = now_channel
      now_channel = arg.to_sym
      puts "Channel is tuned. #{old} => #{now_channel}"
      @since_id = nil
    end
  }
)

Termtter::Client.register_command(
  :name => :reload,
  :author => 'Sora Harakami',
  :exec => lambda {|arg|
    # NOTE: Please edit here as well if reload command in lib/plugins/default/standard_commands.rb was edited.
    args = @since_id ? [{:since_id => @since_id}] : []
    statuses = Termtter::API.call_by_channel(now_channel, *args)
    unless statuses.empty?
      print "\e[0G" + "\e[K" unless win?
      @since_id = statuses[0].id
      Termtter::Client.output(statuses, Termtter::Event.new(:update_friends_timeline, :type => :main))
      Readline.refresh_line if arg =~ /\-r/
    end
  },
  :help => ['reload', 'Reload time line']
)

colorize_channel_cache = {}
Termtter::Client.register_hook(
  :name => :add_channel_line, :point => :pre_output,
  :author => 'Sora Harakami',
  :exec => lambda {|t, e|
    # Additional to channel
    c =
      case e[:type]
      when :list, :lists
        :"#{e[:list_user] == config.user_name ?
          "" : e[:list_user]}/#{e[:list_slug]}"
      when :user
        :"@#{e[:user_name]}"
      when :home_timeline, :main, :friends_timeline
        :main
      when :direct_message, :direct
        :direct
      when :search
        :"#{e[:query]}_search"
      when :reply, :replies
        :replies
      when :show
        :show
      when :favorite, :favorites
        :favorite
      when :multiple
        :multiple
      when :channel
        e[:channel]
      else
        :unknown
      end
    # Add channel text to output text
    otc = config.plugins.channel.short_names.key?(c) ?
      config.plugins.channel.short_names[c] : c
    ccolor = colorize_channel_cache.key?(otc) ?
      colorize_channel_cache[otc] :
      config.plugins.stdout.colors[
        config.plugins.channel.channel_to_hash_proc.call(otc.to_s.gsub(/^\//, "")) %
        config.plugins.stdout.colors.size]
    colorize_channel_cache[otc] = ccolor

    th = "#{config.plugins.channel.colorize ? "<#{ccolor}>":""}#{c.to_s.length > config.plugins.channel.output_length ?
            otc.to_s[0, config.plugins.channel.output_length] : otc.to_s.rjust(config.plugins.channel.output_length)}#{config.plugins.channel.colorize ? "</#{ccolor}>":""}<#{cgray}>| </#{cgray}>"
    th + t
  }
)

# Add auto reloads
config.plugins.channel.auto_reload_channels.each do |c, i|
  since_ids = {}
  Termtter::Client.add_task(:name => "auto_reload_#{c}".to_sym, :interval => i) do
    begin
      if c != now_channel
        # NOTE: Please edit here as well if reload command in lib/plugins/default/standard_commands.rb was edited.
        args = since_ids[c] ? [{:since_id => since_ids[c]}] : []
        statuses = Termtter::API.call_by_channel(c, *args)
        unless statuses.empty?
          print "\e[0G" + "\e[K" unless win?
          since_ids[c] = statuses[0].id
          Termtter::Client.output(statuses, Termtter::Event.new(:"update_#{c}", :type => :channel, :channel => c))
          Readline.refresh_line
        end
      end
    rescue TimeoutError
      # do nothing
    rescue Exception => e
      Termtter::Client.handle_error(e)
    end
  end
end

