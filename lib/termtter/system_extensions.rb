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

require 'dl/import'
module Readline
  begin
    module LIBREADLINE
      if DL.const_defined? :Importable
        extend DL::Importable
      else
        extend DL::Importer
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

def open_browser(url)
  if ENV['KDE_FULL_SESSION'] == 'true'
    system 'kfmclient', 'exec', url
  elsif ENV['GNOME_DESKTOP_SESSION_ID']
    system 'gnome-open', url
# elsif /not found/ =~ `which exo-open`
#   # FIXME: is fungible system('exo-open').nil? for lambda {...}
#   system 'exo-open', url
  else
    case RUBY_PLATFORM.downcase
    when /linux/
      [['xdg-open'], ['x-www-browser'], ['firefox'], ['w3m', '-X']].find do |cmd|
        system *cmd, url
        $?.exitstatus != 127
      end or puts 'Browser not found.'
    when /darwin/
      system 'open', url
    when /mswin(?!ce)|mingw|bccwin/
      system 'start', url
    else
      system 'firefox', url
    end
  end
end

if Readline.respond_to?(:input=)
  # temporary measure for Readline stops other threads problem.
  Readline.input = STDIN
end
