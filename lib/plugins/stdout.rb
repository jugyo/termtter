# -*- coding: utf-8 -*-

require 'termcolor'
require 'erb'
require 'tempfile'

config.plugins.stdout.set_default(:colors, (31..36).to_a + (91..96).to_a)
config.plugins.stdout.set_default(
  :timeline_format,
  '<90><%=time%> [<%=status_id%>]</90> <<%=color%>><%=s.user.screen_name%>: <%=text%></<%=color%>> ' +
  '<90><%=reply_to_status_id ? " (reply_to [#{reply_to_status_id}]) " : ""%><%=source%></90>'
)
config.plugins.stdout.set_default(:enable_pager, true)
config.plugins.stdout.set_default(:pager, 'less -R -f +G')
config.plugins.stdout.set_default(:window_height, 50)
config.plugins.stdout.set_default(:typable_ids, ('aa'..'zz').to_a)
config.plugins.stdout.set_default(:typable_id_prefix, '$')

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
    end

    def next(data)
      id = @ids.shift
      @ids.push id
      @table[id] = data
      id
    end

    def get(id)
      @table[id]
    end
  end

  module Client
    @typable_id_generator = TypableIdGenerator.new(config.plugins.stdout.typable_ids)

    def self.data_to_typable_id(data)
      id = config.plugins.stdout.typable_id_prefix + @typable_id_generator.next(data)
    end

    def self.typable_id_to_data(id)
      @typable_id_generator.get(id)
    end
  end

  class StdOut < Hook
    def initialize
      super(:name => :stdout, :points => [:output])
    end

    def call(statuses, event)
      print_statuses(statuses)
    end

    def print_statuses(statuses, sort = true, time_format = nil)
      return unless statuses and statuses.first
      unless time_format
        t0 = Time.now
        t1 = Time.parse(statuses.first[:created_at])
        t2 = Time.parse(statuses.last[:created_at])
        time_format = 
          if [t0.year, t0.month, t0.day] == [t1.year, t1.month, t1.day] \
            and [t1.year, t1.month, t1.day] == [t2.year, t2.month, t2.day]
            '%H:%M:%S'
          else
            '%y/%m/%d %H:%M'
          end
      end

      output_text = ''
      statuses.each do |s|
        text = TermColor.escape(s.text)
        color = config.plugins.stdout.colors[s.user.id.to_i % config.plugins.stdout.colors.size]
        status_id = Termtter::Client.data_to_typable_id(s.id)
        reply_to_status_id =
          if s.in_reply_to_status_id.nil?
            nil
          else
            Termtter::Client.data_to_typable_id(s.in_reply_to_status_id)
          end

        time = "(#{Time.parse(s.created_at).strftime(time_format)})"
        source =
          case s.source
          when />(.*?)</ then $1
          when 'web' then 'web'
          end

        erbed_text = ERB.new(config.plugins.stdout.timeline_format).result(binding)
        output_text << TermColor.parse(erbed_text) + "\n"
      end

      if config.plugins.stdout.enable_pager && ENV['LINES'] && statuses.size > ENV['LINES'].to_i
        file = Tempfile.new('termtter')
        file.print output_text
        file.close
        system "#{config.plugins.stdout.pager} #{file.path}"
        file.close(true)
      else
        print output_text
      end
    end
  end

  Client.register_hook(StdOut.new)

  Client.register_hook(
    :name => :stdout_typable_id,
    :point => /^modify_arg_for_.*/,
    :exec => lambda { |cmd, arg|
      if arg
        prefix = config.plugins.stdout.typable_id_prefix
        arg.gsub!(/#{Regexp.quote(prefix)}\w+/) do |id|
          Termtter::Client.typable_id_to_data(id[1..-1]) || id
        end
      end
      arg
    }
  )
end

# stdout.rb
#   output statuses to stdout
# example config
#   config.plugins.stdout.colors = [:none, :red, :green, :yellow, :blue, :magenta, :cyan]
#   config.plugins.stdout.timeline_format = '<90><%=time%> [<%=status_id%>]</90> <<%=color%>><%=s.user.screen_name%>: <%=text%></<%=color%>> ' +
#                                           '<90><%=reply_to_status_id ? " (reply_to [#{reply_to_status_id}]) " : ""%><%=source%></90>'
