# -*- coding: utf-8 -*-

require 'termcolor'
require 'erb'

configatron.plugins.stdout.set_default(
  :colors,
  [:none, :red, :green, :yellow, :blue, :magenta, :cyan])
configatron.plugins.stdout.set_default(
  :timeline_format,
  '<90><%=time%></90> <<%=status_color%>><%=status%></<%=status_color%>> <90><%=id%></90>')

$highline = HighLine.new

def color(str, value)
  return str if value == :none
  case value
  when String, Symbol
    $highline.color(str, value)
  else
    "\e[#{value}m#{str}\e[0m"
  end
end

module Termtter::Client

  def self.print_statuses(statuses, sort = true, time_format = '%H:%M:%S')
    (sort ? statuses.sort_by{ |s| s.id} : statuses).each do |s|
      text = s.text
      status_color = configatron.plugins.stdout.colors[s.user_id.to_i.hash % configatron.plugins.stdout.colors.size]
      status = "#{s.user_screen_name}: #{text}"
      if s.in_reply_to_status_id
        status += " (reply to #{s.in_reply_to_status_id})"
      end

      time = "(#{s.created_at.strftime(time_format)})"
      id = s.id
      erbed_text = ERB.new(configatron.plugins.stdout.timeline_format).result(binding)
      puts TermColor.parse(erbed_text)
    end
  end

  def self.print_statuses_with_date(statuses, sort = true)
    print_statuses(statuses, sort, '%m-%d %H:%M')
  end

  add_hook do |statuses, event|
    next if statuses.empty?

    case event
    when :update_friends_timeline, :list_friends_timeline
      print_statuses(statuses)
    when :search, :list_user_timeline, :show, :replies
      print_statuses_with_date(statuses)
    end
  end

end
# stdout.rb
#   output statuses to stdout
# example config
#   configatron.plugins.stdout.colors = [:none, :red, :green, :yellow, :blue, :magenta, :cyan]
#   configatron.plugins.stdout.timeline_format = '<90><%=time%></90> <<%=status_color%>><%=status%></<%=status_color%>> <90><%=id%></90>'
