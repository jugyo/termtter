require 'highline'
require 'erb'

configatron.plugins.stdout.set_default(
  :colors,
  [:none, :red, :green, :yellow, :blue, :magenta, :cyan])
configatron.plugins.stdout.set_default(
  :timeline_format,
  '<%= color(time, 90) %> <%= color(status, status_color) %> <%= color(id, 90) %>')

$highline = HighLine.new

if win?
  require 'kconv'
  require 'Win32API'
  STD_OUTPUT_HANDLE = 0xFFFFFFF5
  $wSetConsoleTextAttribute = Win32API.new('kernel32','SetConsoleTextAttribute','II','I')
  $wGetConsoleScreenBufferInfo = Win32API.new("kernel32", "GetConsoleScreenBufferInfo", ['l', 'p'], 'i')
  $wGetStdHandle = Win32API.new('kernel32','GetStdHandle','I','I')

  $hStdOut = $wGetStdHandle.call(STD_OUTPUT_HANDLE)
  lpBuffer = ' ' * 22
  $wGetConsoleScreenBufferInfo.call($hStdOut, lpBuffer)
  $oldColor = lpBuffer.unpack('SSSSSssssSS')[4]

  $colorMap = {
    0 => 7,     # black/white
    37 => 8,     # white/intensity
    31 => 4 + 8, # red/red
    32 => 2 + 8, # green/green
    33 => 6 + 8, # yellow/yellow
    34 => 1 + 8, # blue/blue
    35 => 5 + 8, # magenta/purple
    36 => 3 + 8, # cyan/aqua
    90 => 7,     # erase/white
  }
  def puts(str)
    str = str.to_s.tosjis
    tokens = str.split(/(\e\[\d+m)/)
    tokens.each do |token|
      if token =~ /\e\[(\d+)m/
        $wSetConsoleTextAttribute.call $hStdOut, $colorMap[$1.to_i].to_i
      else
        STDOUT.print token
      end
    end
    $wSetConsoleTextAttribute.call $hStdOut, $oldColor
    STDOUT.puts
  end
end

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
    (sort ? statuses.sort_by{ |s| s.created_at} : statuses).each do |s|
      text = s.text
      status_color = configatron.plugins.stdout.colors[s.user_screen_name.hash % configatron.plugins.stdout.colors.size]
      status = "#{s.user_screen_name}: #{text}"
      if s.in_reply_to_status_id
        status += " (reply to #{s.in_reply_to_status_id})"
      end
      
      time = "(#{s.created_at.strftime(time_format)})"
      id = s.id
      puts ERB.new(configatron.plugins.stdout.timeline_format).result(binding)
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
#   configatron.plugins.stdout.timeline_format = '<%= color(time, 90) %> <%= color(status, status_color) %> <%= color(id, 90) %>'
