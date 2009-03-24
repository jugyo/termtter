# -*- coding: utf-8 -*-

require 'termcolor'
require 'erb'

config.plugins.stdout.set_default(
  :colors,
  [:none, :red, :green, :yellow, :blue, :magenta, :cyan])
config.plugins.stdout.set_default(
  :timeline_format,
  '<90><%=time%></90> <<%=status_color%>><%=status%></<%=status_color%>> <90><%=id%></90>')
config.plugins.stdout.set_default(:search_highlight_format, '<on_magenta><white>\1</white></on_magenta>')

config.plugins.stdout.set_default(:enable_pager, true)
config.plugins.stdout.set_default(:pager, 'less -R -f +G')
config.plugins.stdout.set_default(:window_height, 50)

module Termtter
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
        text = s.text
        status_color = config.plugins.stdout.colors[s.user.id.hash % config.plugins.stdout.colors.size]
        status = "#{s.user.screen_name}: #{text}"
        if s.in_reply_to_status_id
          status += " (repl. to #{s.in_reply_to_status_id})"
        end

        time = "(#{Time.parse(s.created_at).strftime(time_format)})"
        id = s.id
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
end

# stdout.rb
#   output statuses to stdout
# example config
#   config.plugins.stdout.colors = [:none, :red, :green, :yellow, :blue, :magenta, :cyan]
#   config.plugins.stdout.timeline_format = '<90><%=time%></90> <<%=status_color%>><%=status%></<%=status_color%>> <90><%=id%></90>'
