# -*- coding: utf-8 -*-

require 'termcolor'
require 'erb'

config.plugins.stdout.set_default(
  :colors,
  [:none, :red, :green, :yellow, :blue, :magenta, :cyan])
config.plugins.stdout.set_default(
  :timeline_format,
  '<90><%=time%></90> <<%=status_color%>><%=status%></<%=status_color%>> <90><%=id%></90>')
config.plugins.stdout.set_default(:search_highlihgt_format, '<on_magenta><white>\1</white></on_magenta>')

module Termtter
  class StdOut < Hook
    def initialize
      super(:name => :stdout, :points => [:output])
    end

    def execute(statuses, event)
      print_statuses(statuses)
    end

    def print_statuses(statuses, sort = true, time_format = '%H:%M:%S')
      (sort ? statuses.sort_by{ |s| s[:id]} : statuses).each do |s|
        text = s[:post_text]
        status_color = config.plugins.stdout.colors[s[:user_id].hash % config.plugins.stdout.colors.size]
        status = "#{s[:screen_name]}: #{text}"
        if s[:in_reply_to_status_id]
          status += " (repl. to #{s[:in_reply_to_status_id]})"
        end

        time = "(#{Time.parse(s[:created_at]).strftime(time_format)})"
        id = s[:id]
        erbed_text = ERB.new(config.plugins.stdout.timeline_format).result(binding)
        puts TermColor.parse(erbed_text)
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
