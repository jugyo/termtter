require 'erb'

module Termtter::Client

  # standard commands

  add_command /^(update|u)\s+(.*)/ do |m, t|
    text = ERB.new(m[2]).result(binding).gsub(/\n/, ' ')
    unless text.empty?
      t.update_status(text)
      puts "=> #{text}"
    end
  end

  add_command /^(direct|d)\s+([^\s]+)\s+(.*)\s*$/ do |m, t|
    user = m[2]
    text = ERB.new(m[3]).result(binding).gsub(/\n/, ' ')
    unless text.empty?
      t.direct_message(user, text)
      puts "=> to:#{user} message:#{text}"
    end
  end

  register_command(
    :name => :profile, :alias => :p,
    :exec_proc => proc {|arg|
      user = Termtter::API.twitter.get_user_profile(arg)
      attrs = %w[ name screen_name url description profile_image_url location protected following
          friends_count followers_count statuses_count favourites_count
          id time_zone created_at utc_offset notifications
      ]
      label_width = attrs.map{|i|i.size}.max
      attrs.each do |attr|
        value = user.__send__(attr.to_sym)
        puts "#{attr.gsub('_', ' ').rjust(label_width)}: #{value}"
      end
    },
    :completion_proc => proc {|cmd, arg|
      find_user_candidates arg, "#{cmd} %s"
    }
  )

  add_command /^(list|l)\s*$/ do |m, t|
    statuses = t.get_friends_timeline()
    call_hooks(statuses, :list_friends_timeline, t)
  end

  add_command /^(list|l)\s+([^\s]+)/ do |m, t|
    statuses = t.get_user_timeline(m[2])
    call_hooks(statuses, :list_user_timeline, t)
  end

  register_command(
    :name => :search, :aliases => [:s],
    :exec_proc => proc {|arg|
      call_hooks(Termtter::API.twitter.search(arg), :search)
    }
  )

  register_command(
    :name => :replies, :aliases => [:r],
    :exec_proc => proc {
      call_hooks(Termtter::API.twitter.replies(), :replies)
    }
  )

  add_command /^show(s)?\s+(?:[\w\d]+:)?(\d+)/ do |m, t|
    call_hooks(t.show(m[2], m[1]), :show, t)
  end

  # TODO: Change colors when remaining_hits is low.
  # TODO: Simmulate remaining_hits.
  register_command(
    :name => :limit, :aliases => ['lm'],
    :exec_proc => proc {|arg|
      limit = Termtter::API.twitter.get_rate_limit_status
      remaining_time = "%dmin %dsec" % (limit.reset_time - Time.now).divmod(60)
      remaining_color =
        case limit.remaining_hits / limit.hourly_limit.to_f
        when 0.2..0.4 then :yellow
        when 0..0.2   then :red
        else               :green
        end
      puts "=> #{color(limit.remaining_hits, remaining_color)}/#{limit.hourly_limit} until #{limit.reset_time} (#{remaining_time} remaining)"
    },
    :help => ["limit,lm", "Show the API limit status"]
  )

  register_command( 
    :name => :pause,
    :exec_proc => proc {|arg| pause},
    :help => ["pause", "Pause updating"]
  )

  register_command(
    :name => :resume,
    :exec_proc => proc {|arg| resume},
    :help => ["resume", "Resume updating"]
  )

  register_command(
    :name => :exit, :aliases => ['e'],
    :exec_proc => proc {|arg| exit},
    :help => ['exit,e', 'Exit']
  )

  add_command /^(help|h)\s*$/ do |m, t|
    # TODO: migrate to use Termtter::Command#help
    helps = [
      ["help,h", "Print this help message"],
      ["list,l", "List the posts in your friends timeline"],
      ["list,l USERNAME", "List the posts in the the given user's timeline"],
      ["update,u TEXT", "Post a new message"],
      ["direct,d @USERNAME TEXT", "Send direct message"],
      ["profile,p USERNAME", "Show user's profile"],
      ["replies,r", "List the most recent @replies for the authenticating user"],
      ["search,s TEXT", "Search for Twitter"],
      ["show ID", "Show a single status"]
    ]
    helps += @@helps
    helps += @@new_commands.map {|name, command| command.help}
    helps.compact!
    puts formatted_help(helps)
  end

  add_command /^eval\s+(.*)$/ do |m, t|
    begin
      result = eval(m[1]) unless m[1].empty?
      puts "=> #{result.inspect}"
    rescue SyntaxError => e
      puts e
    end
  end

  add_command /^!(!)?\s*(.*)$/ do |m, t|
    begin
      result = `#{m[2]}` unless m[2].empty?
      unless m[1].nil? || result.empty?
        t.update_status(result.gsub("\n", " "))
      end
      puts "=> #{result}"
    rescue => e
      puts e
    end
  end

  def self.formatted_help(helps)
    helps = helps.sort_by{|help| help[0]}
    width = helps.map {|n, d| n.size }.max
    space = 3
    helps.map {|name, desc|
      name.to_s.ljust(width + space) + desc.to_s
    }.join("\n")
  end

  # completion for standard commands

  require 'set'
  public_storage[:users] ||= Set.new
  public_storage[:status_ids] ||= Set.new

  add_hook do |statuses, event, t|
    statuses.each do |s|
      public_storage[:users].add(s.user_screen_name)
      public_storage[:users] += s.text.scan(/@([a-zA-Z_0-9]*)/).flatten
      public_storage[:status_ids].add(s.id.to_s)
      public_storage[:status_ids].add(s.in_reply_to_status_id.to_s) if s.in_reply_to_status_id
    end
  end

  def self.find_status_id_candidates(a, b, u = nil)
    candidates = public_storage[:status_ids].to_a
    if u && c = public_storage[:log].select {|s| s.user_screen_name == u }.map {|s| s.id.to_s }
      candidates = c unless c.empty?
    end
    if a.empty?
      candidates
    else
      candidates.grep(/#{Regexp.quote a}/)
    end.
    map {|u| b % u }
  end

  def self.find_user_candidates(a, b)
    if a.empty?
      public_storage[:users].to_a
    else
      public_storage[:users].grep(/^#{Regexp.quote a}/i)
    end.
    map {|u| b % u }
  end

  add_completion do |input|
    standard_commands = %w[exit help list pause profile update direct resume replies search show limit]
    case input
    when /^(list|l)?\s+(.*)/
      find_user_candidates $2, "#{$1} %s"
    when /^(update|u)\s+(.*)@([^\s]*)$/
      find_user_candidates $3, "#{$1} #{$2}@%s"
    when /^(direct|d)\s+(.*)/
      find_user_candidates $2, "#{$1} %s"
    when /^show(s)?\s+(([\w\d]+):)?\s*(.*)/
      if $2
        find_status_id_candidates $4, "show#{$1} #{$2}%s", $3
      else
        result = find_user_candidates $4, "show#{$1} %s:"
        result = find_status_id_candidates $4, "show#{$1} %s"  if result.empty?
        result
      end
    else
      standard_commands.grep(/^#{Regexp.quote input}/)
    end
  end

end
