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
      status_color = config.plugins.stdout.colors[s.user.screen_name.hash % config.plugins.stdout.colors.size]
      status = "#{s.user.screen_name}: #{text}"
      if s.in_reply_to_status_id
        status += " (repl. to #{s.in_reply_to_status_id})"
      end

      time = "(#{Time.parse(s.created_at).strftime(time_format)})"
      id = s.id
      erbed_text = ERB.new(config.plugins.stdout.timeline_format).result(binding)
      puts TermColor.parse(erbed_text)
    end
  end

  def self.print_statuses_with_date(statuses, sort = true)
    print_statuses(statuses, sort, '%m-%d %H:%M')
  end

  def self.print_search_results(result, time_format = '%H:%M:%S')
    result.results.sort_by{|r| r.created_at}.each do |r|
      text = r.text.
                gsub(/(\n|\r)/, '').
                gsub(/(#{Regexp.escape(result.query)})/i, configatron.search.highlihgt_text_format)
      status_color = configatron.plugins.stdout.colors[r.from_user_id.to_i.hash % configatron.plugins.stdout.colors.size]
      status = "#{r.from_user}: #{text}"
      time = "(#{Time.parse(r.created_at).strftime(time_format)})"
      id = r.id
      erbed_text = ERB.new(configatron.plugins.stdout.timeline_format).result(binding)
      puts TermColor.parse(erbed_text)
    end
  end

  add_hook do |result, event|
    case event
    when :update_friends_timeline, :list_friends_timeline
      print_statuses(result) unless result.empty?
    when :list_user_timeline, :show, :replies
      print_statuses_with_date(result) unless result.empty?
    when :search
      print_search_results(result)
    end
  end

end
# stdout.rb
#   output statuses to stdout
# example config
#   config.plugins.stdout.colors = [:none, :red, :green, :yellow, :blue, :magenta, :cyan]
#   config.plugins.stdout.timeline_format = '<90><%=time%></90> <<%=status_color%>><%=status%></<%=status_color%>> <90><%=id%></90>'
