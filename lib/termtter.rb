$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'json'
require 'net/https'
require 'open-uri'
require 'cgi'
require 'readline'
require 'enumerator'
require 'parsedate'
require 'configatron'

Thread.abort_on_exception = true

configatron.set_default(:update_interval, 300)
configatron.set_default(:prompt, '> ')
configatron.set_default(:enable_ssl, false)
configatron.proxy.set_default(:port, '8080')

require 'termtter/twitter'
require 'termtter/connection'
require 'termtter/status'
require 'termtter/client'

module Termtter
  VERSION = '0.7.6'
  APP_NAME = 'termtter'
  CONF_FILE = '~/.termtterrc' # still does not use
  CONF_DIR = '~/.termtter' # still does not use
end

if RUBY_VERSION < '1.8.7'
  class Array
    def take(n) self[0...n] end
  end
end

def win?
  RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|bccwin/
end

if win?
  require 'iconv'
  require 'Win32API'
  $wGetACP = Win32API.new('kernel32','GetACP','','I')

  module Readline
    $iconv_sj_to_u8 = Iconv.new('UTF-8', "CP#{$wGetACP.call()}")
    alias :old_readline :readline
    def readline(*a)
      str = old_readline(*a)
      out = ''
      loop do
        begin
          out << $iconv_sj_to_u8.iconv(str)
          break
        rescue Iconv::Failure
          out << "#{$!.success}?"
          str = $!.failed[1..-1]
        end
      end
      return out
    end
    module_function :old_readline, :readline
  end

  $wSetConsoleTextAttribute = Win32API.new('kernel32','SetConsoleTextAttribute','II','I')
  $wGetConsoleScreenBufferInfo = Win32API.new("kernel32", "GetConsoleScreenBufferInfo", ['l', 'p'], 'i')
  $wGetStdHandle = Win32API.new('kernel32','GetStdHandle','I','I')
  $wGetACP = Win32API.new('kernel32','GetACP','','I')

  $hStdOut = $wGetStdHandle.call(0xFFFFFFF5)
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
  $iconv_u8_to_sj = Iconv.new("CP#{$wGetACP.call()}", 'UTF-8')
  def puts(str)
    #str.to_s.tosjis.split(/(\e\[\d+m)/).each do |token|
    str.to_s.gsub("\xef\xbd\x9e", "\xe3\x80\x9c").split(/(\e\[\d+m)/).each do |token|
      if token =~ /\e\[(\d+)m/
        $wSetConsoleTextAttribute.call $hStdOut, $colorMap[$1.to_i].to_i
      else
        loop do
          begin
            STDOUT.print $iconv_u8_to_sj.iconv(token)
            break
          rescue Iconv::Failure
            STDOUT.print "#{$!.success}?"
            token = $!.failed[1..-1]
          end
        end
      end
    end
    $wSetConsoleTextAttribute.call $hStdOut, $oldColor
    STDOUT.puts
    $iconv_u8_to_sj.iconv(nil)
  end
end

def plugin(s)
  require "plugin/#{s}"
end

def filter(s)
  load "filter/#{s}.rb"
rescue LoadError
  raise
else
  Termtter::Client.public_storage[:filters] ||= []
  Termtter::Client.public_storage[:filters] << s
  true
end

$:.unshift(Termtter::CONF_DIR) # still does not use

