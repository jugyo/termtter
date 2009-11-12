# -*- coding: utf-8 -*-

require 'termcolor'
require 'erb'
require 'tempfile'

config.plugins.stdout.set_default(:colors, (31..36).to_a + (91..96).to_a)
config.plugins.stdout.set_default(
  :timeline_format,
  [
    '<90><%=time%> [<%=status_id%>]</90> ',
    '||>',
    '<<%=color%>><%=s.user.screen_name%></<%=color%>>: ',
    '<%=text%> ',
    '<90>',
    '<%=reply_to_status_id ? " (reply_to [#{reply_to_status_id}]) " : ""%>',
    '<%=retweeted_status_id ? " (retweet_to [#{retweeted_status_id}]) " : ""%>',
    '<%=source%><%=s.user.protected ? "[P]" : ""%>',
    '</90>'
  ].join('')
)
config.plugins.stdout.set_default(:sweets, %w[jugyo ujm sora_h lingr_termtter termtter hitode909 nanki sixeight])
config.plugins.stdout.set_default(:sweet_color, 'red')
config.plugins.stdout.set_default(:time_format_today, '%H:%M:%S')
config.plugins.stdout.set_default(:time_format_not_today, '%y/%m/%d %H:%M')
config.plugins.stdout.set_default(:enable_pager, false)
config.plugins.stdout.set_default(:pager, 'less -R -f +G')
config.plugins.stdout.set_default(:window_height, 50)
config.plugins.stdout.set_default(:typable_ids, ('aa'..'zz').to_a)
config.plugins.stdout.set_default(:typable_id_prefix, '$')
config.plugins.stdout.set_default(:show_reply_chain, true)
config.plugins.stdout.set_default(:indent_format, %q("#{'    ' * (indent - 1)}  → "))
config.plugins.stdout.set_default(:max_indent_level, 1)
config.plugins.stdout.set_default(
  :screen_name_to_hash_proc, lambda { |screen_name| screen_name.to_i(36) })

module Termtter
  class TypableIdGenerator
    def initialize(ids)
      if not ids.kind_of?(Array)
        raise ArgumentError, 'ids should be an Array'
      elsif ids.empty?
        raise ArgumentError, 'ids should not be empty'
      end
      @ids = ids
      @table = {}
      @rtable = {}
    end

    def next(data)
      id = @ids.shift
      @ids.push id
      @rtable.delete(@table[id])
      @table[id] = data
      @rtable[data] = id
      id
    end

    def get(id)
      @table[id]
    end

    def get_id(data)
      @rtable[data] || self.next(data)
    end
  end

  module Client
    @typable_id_generator = TypableIdGenerator.new(config.plugins.stdout.typable_ids)

    def self.data_to_typable_id(data)
      id = config.plugins.stdout.typable_id_prefix +
        @typable_id_generator.get_id(data)
    end

    def self.typable_id_to_data(id)
      @typable_id_generator.get(id)
    end

    def self.time_format_for(statuses)
      t0 = Time.now
      t1 = Time.parse(statuses.first[:created_at])
      t2 = Time.parse(statuses.last[:created_at])
      if [t0.year, t0.month, t0.day] == [t1.year, t1.month, t1.day] \
        and [t1.year, t1.month, t1.day] == [t2.year, t2.month, t2.day]
        config.plugins.stdout.time_format_today
      else
        config.plugins.stdout.time_format_not_today
      end
    end
  end

  class StdOut < Hook
    def initialize
      super(:name => :stdout, :points => [:output])
    end

    def call(statuses, event)
      print_statuses(statuses, event)
    end

    private
    def print_statuses(statuses, event, sort = true, time_format = nil)
      return unless statuses and statuses.first
      time_format ||= Termtter::Client.time_format_for statuses

      output = []
      statuses.each do |s|
        output << status_line(s, time_format, event)
      end

      justs = config.plugins.stdout.timeline_format.scan(/\|\|([><])/).map{|v|v == '<' ? :ljust : :rjust}
      justs.unshift :ljust

      output = format_column(output, justs)

      output.map! do |t|
        t = Client.get_hooks(:pre_output).inject(t) {|result, hook|
          Termtter::Client.logger.debug "stdout status_line: call hook :pre_output #{hook.inspect}"
          hook.call(result, event)
        }
      end

      if config.plugins.stdout.enable_pager &&
        ENV['LINES'] &&
        statuses.size > ENV['LINES'].to_i
          file = Tempfile.new('termtter')
          file.print output_text
          file.close
          system "#{config.plugins.stdout.pager} #{file.path}"
          file.close(true)
      else
        puts output
      end
    end

    def uncolored(str)
      str.gsub(/\e\[([0-9]+m)/, '')
    end

    def format_column(statuses, justs)
      cols = statuses.first.first.size
      ws = [0] * cols

      ws = statuses.inject(ws) do |r, v|
        [r, v.first].transpose.map{|max, col|[max, uncolored(col).size].max}
      end

      ws[-1] = 0

      statuses.map! do |lines|
        left = 0
        [ws, lines.first, justs].transpose.map do |w, s, just|
          left += w
          s.inject([]) do |r, line|
            adjusted = line.__send__(just, w + line.size - uncolored(line).size)
            margin = r.empty? ? '' : ' ' * (left - w)
            r << margin + adjusted
          end
        end
      end

      statuses.map!{|v|v.join}
    end

    # [status, in_reply_to...]
    def status_line(s, time_format, event, indent = 0)
      return [] unless s
      text = TermColor.escape(s.text)
      color = color_of_user(s.user)
      status_id = Termtter::Client.data_to_typable_id(s.id)
      reply_to_status_id =
        if s.in_reply_to_status_id
          Termtter::Client.data_to_typable_id(s.in_reply_to_status_id)
        else
          nil
        end

      retweeted_status_id =
        if s.retweeted_status
          Termtter::Client.data_to_typable_id(s.retweeted_status.id)
        else
          nil
        end

      time = "(#{Time.parse(s.created_at).strftime(time_format)})"
      source =
        case s.source
        when />(.*?)</ then $1
        when 'web' then 'web'
        end

      text = colorize_users(text)

      indent_text = indent > 0 ? eval(config.plugins.stdout.indent_format) : ''

      timeline_formats = config.plugins.stdout.timeline_format.split(/\|\|[><]/)
      erbed_texts = timeline_formats.map do |timeline_format|
        t = ERB.new(timeline_format).result(binding)
        t = Client.get_hooks(:pre_coloring).inject(t) {|result, hook|
          Termtter::Client.logger.debug "stdout status_line: call hook :pre_coloring #{hook.inspect}"
          hook.call(result, event)
        }
        t = TermColor.parse(t)
        TermColor.unescape(t)
      end

      if indent > 0
        erbed_texts = [indent_text, erbed_texts.join.split(/[\r\n]/).join]
      end

      texts = [erbed_texts]

      if config.plugins.stdout.show_reply_chain && s.in_reply_to_status_id
        indent += 1
        unless indent > config.plugins.stdout.max_indent_level
          begin
            if status = Termtter::API.twitter.cached_status(s.in_reply_to_status_id)
              texts.concat status_line(status, time_format, event, indent)
            end
          rescue Rubytter::APIError
          end
        end
      end

      texts
    end

    def colorize_users(text)
      text.gsub(/@([0-9A-Za-z_]+)/) do |i|
        color = color_of_screen_name($1)
        "<#{color}>#{i}</#{color}>"
      end
    end

    def color_of_user(user)
      color_of_screen_name(user.screen_name)
    end

    def color_of_screen_name(screen_name)
      return color_of_screen_name_cache[screen_name] if
        color_of_screen_name_cache.key?(screen_name)
      num = screen_name_to_hash(screen_name)
      color = config.plugins.stdout.instance_eval {
        sweets.include?(screen_name) ?
          sweet_color : colors[num % colors.size]
      }
      color_of_screen_name_cache[screen_name] = color
      color_of_screen_name_cache[screen_name]
    end

    def screen_name_to_hash(screen_name)
      config.plugins.stdout.screen_name_to_hash_proc.
        call(screen_name)
    end

    def color_of_screen_name_cache
      @color_of_screen_name_cache ||= {}
    end
  end

  Client.register_hook(StdOut.new)

  Client.register_hook(
    :name => :stdout_typable_id,
    :point => /^modify_arg_for_.*/,
    :exec => lambda { |cmd, arg|
      if arg
        prefix = config.plugins.stdout.typable_id_prefix
        arg.gsub(/#{Regexp.quote(prefix)}\w+/) do |id|
          Termtter::Client.typable_id_to_data(id[1..-1]) || id
        end
      else
        arg
      end
    }
  )
end

# stdout.rb
#   output statuses to stdout
# example config
#   config.plugins.stdout.colors =
#     [:none, :red, :green, :yellow, :blue, :magenta, :cyan]
#   config.plugins.stdout.timeline_format =
#     '<90><%=time%> [<%=status_id%>]</90> <<%=color%>><%=s.user.screen_name%>: <%=text%></<%=color%>> ' +
#     '<90><%=reply_to_status_id ? " (reply_to [#{reply_to_status_id}]) " : ""%><%=source%></90>'
