# -*- coding: utf-8 -*-

require 'termcolor'
require 'erb'
require 'tempfile'

config.plugins.stdout.set_default(:colors, (31..36).to_a + (91..96).to_a)
config.plugins.stdout.set_default(
  :timeline_format,
  '<90>(<%=time%>) [<%=status_id%>]</90> ||><<%=color%>><%=s.user.screen_name%></<%=color%>>: ||<<%=text%> ' +
  '<90><%=reply_to_status_id ? " (reply_to [#{reply_to_status_id}]) " : ""%><%=source%><%=s.user.protected ? "[P]" : ""%></90>'
)
config.plugins.stdout.set_default(:time_format_today, '%H:%M:%S')
config.plugins.stdout.set_default(:time_format_not_today, '%y/%m/%d %H:%M')
config.plugins.stdout.set_default(:enable_pager, false)
config.plugins.stdout.set_default(:pager, 'less -R -f +G')
config.plugins.stdout.set_default(:window_height, 50)
config.plugins.stdout.set_default(:typable_ids, ('aa'..'zz').to_a)
config.plugins.stdout.set_default(:typable_id_prefix, '$')
config.plugins.stdout.set_default(:show_as_thread, false) # db plugin is required

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
      id = config.plugins.stdout.typable_id_prefix + @typable_id_generator.get_id(data)
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

      outputs = []
      not_replies = []
      statuses.each do |s|
        not_replies << outputs.size
        outputs.concat status_line(s, time_format, event)
      end

      justs = config.plugins.stdout.timeline_format.scan(/\|\|([><])/).map{|v|v == '<' ? :ljust : :rjust}
      justs.unshift :ljust

      format_column(outputs, not_replies, justs)

      if config.plugins.stdout.enable_pager && ENV['LINES'] && statuses.size > ENV['LINES'].to_i
        file = Tempfile.new('termtter')
        file.puts outputs
        file.close
        system "#{config.plugins.stdout.pager} #{file.path}"
        file.close(true)
      else
        puts outputs
      end
    end

    def uncolored(str)
      str.gsub(/\e\[([0-9]+m)/, '')
    end

    def format_column(lines, not_replies, justs)
      array = not_replies.map{|i|lines[i]}

      cols = array.first.size
      ws = [0] * cols

      ws = array.inject(ws){|r,v|[r, v].transpose.map{|max, col|
        [max, uncolored(col).size].max}}

      ws[ws.length-1] = 0

      not_replies.each do |i|
        v = lines[i]
        left = 0
        lines[i] = [ws, v, justs].transpose.map do |w, s, just|
          first = true
          left += w
          s.map do |line|
            adjusted = line.__send__(just, w + line.size - uncolored(line).size)
            margin = first ? '' : ' ' * (left - w)
            first = false
            margin + adjusted
          end
        end
      end

      lines.map!{|v|v.join}
    end

    # [status, in_reply_to...]
    def status_line(s, time_format, event, indent = 0)
      return [] unless s
      text = TermColor.escape(s.text)
      color = config.plugins.stdout.colors[s.user.id.to_i % config.plugins.stdout.colors.size]
      status_id = Termtter::Client.data_to_typable_id(s.id)
      reply_to_status_id =
        if s.in_reply_to_status_id.nil?
          nil
        else
          Termtter::Client.data_to_typable_id(s.in_reply_to_status_id)
        end

      time = "#{Time.parse(s.created_at).strftime(time_format)}"
      time = Client.get_hooks(:prepare_time).inject(time){|result, hook| hook.call(result, event)}

      source =
        case s.source
        when />(.*?)</ then $1
        when 'web' then 'web'
        end

      source = Client.get_hooks(:prepare_source).inject(source){|result, hook| hook.call(result, event)}
      screen_name = Client.get_hooks(:prepare_screenname).inject(s.user.screen_name){|result, hook|
        hook.call(result, event)
      }

      formats = config.plugins.stdout.timeline_format.split(/\|\|[><]/)

      erbed_texts = formats.map do |format|
        t = ERB.new(format).result(binding)
        t = Client.get_hooks(:pre_coloring).inject(t){|result, hook| hook.call(result, event)}
        t = TermColor.parse(t)
        TermColor.unescape(t)
      end

      if indent > 0
        indent_text = "#{'    ' * (indent - 1)} ┗ "
        erbed_texts = [indent_text, erbed_texts.join.split(/[\r\n]/).join]
      end

      texts = [erbed_texts]

      if config.plugins.stdout.show_as_thread && s.in_reply_to_status_id
        texts.concat status_line(Status[s.in_reply_to_status_id], time_format, event, indent + 1)
      end

      texts
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
#   config.plugins.stdout.colors = [:none, :red, :green, :yellow, :blue, :magenta, :cyan]
#   config.plugins.stdout.timeline_format = '<90><%=time%> [<%=status_id%>]</90> <<%=color%>><%=s.user.screen_name%>: <%=text%></<%=color%>> ' +
#                                           '<90><%=reply_to_status_id ? " (reply_to [#{reply_to_status_id}]) " : ""%><%=source%></90>'
