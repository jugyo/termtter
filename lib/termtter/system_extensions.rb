# -*- coding: utf-8 -*-

def win?
  !!(RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|bccwin|cygwin/)
end

require 'termtter/system_extensions/windows' if win?
require 'termtter/system_extensions/core_compatibles'
require 'termtter/system_extensions/termtter_compatibles'

unless Readline.const_defined?(:NATIVE_REFRESH_LINE_METHOD)
  # Latest 'readline.so' has native 'refresh_line' method.
  Readline::NATIVE_REFRESH_LINE_METHOD = Readline.respond_to?(:refresh_line)
end

require 'fiddle/import'
module Readline
  begin
    module LIBREADLINE
      if Fiddle.const_defined? :Importable
        extend Fiddle::Importable
      else
        extend Fiddle::Importer
      end
      pathes = Array(ENV['TERMTTER_EXT_LIB'] || [
        '/usr/lib64/libreadline.so',
        '/usr/local/lib64/libreadline.so',
        '/usr/local/lib/libreadline.dylib',
        '/opt/local/lib/libreadline.dylib',
        '/usr/lib/libreadline.so',
        '/usr/local/lib/libreadline.so',
        Dir.glob('/lib/libreadline.so*')[-1] || '', # '' is dummy
        File.join(Gem.bindir, 'readline.dll')
      ])
      dlload(pathes.find { |path| File.exist?(path)})
      extern 'int rl_parse_and_bind (char *)'
    end
    def self.rl_parse_and_bind(str)
      LIBREADLINE.rl_parse_and_bind(str.to_s)
    end
    unless Readline::NATIVE_REFRESH_LINE_METHOD
      module LIBREADLINE
        extern 'int rl_refresh_line(int, int)'
      end
      def self.refresh_line
        LIBREADLINE.rl_refresh_line(0, 0)
      end
    end
  rescue Exception
    def self.rl_parse_and_bind(str);end
    def self.refresh_line;end unless Readline::NATIVE_REFRESH_LINE_METHOD
  end
end

require 'highline'
def create_highline
  HighLine.track_eof = false
  if $stdin.respond_to?(:getbyte) # for ruby1.9
    def $stdin.getc; getbyte
    end
  end
  HighLine.new($stdin)
end

class BrowserNotFound < StandardError; end

def open_browser(url)
  found = case RUBY_PLATFORM.downcase
  when /linux/
    [['xdg-open'], ['x-www-browser'], ['firefox'], ['w3m', '-X']]
  when /darwin/
    [['open']]
  when /mswin(?!ce)|mingw|bccwin/
    [['start']]
  else
    [['xdg-open'], ['firefox'], ['w3m', '-X']]
  end.find do |cmd|
    system *(cmd.dup << url)
    $?.exitstatus != 127
  end
  if found
    # Kernel::__method__ is not suppoted in Ruby 1.8.6 or earlier.
    define_method(:open_browser) {|url| system *(found.dup << url) }
  else
    raise BrowserNotFound
  end
end

if Readline.respond_to?(:input=)
  # temporary measure for Readline stops other threads problem.
  Readline.input = STDIN
end

class String
  if 'あ'.size == 1
    alias_method :charsize, :size
  else
    def charsize; split(//u).size; end
  end
end
