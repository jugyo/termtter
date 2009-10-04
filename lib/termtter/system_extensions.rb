# -*- coding: utf-8 -*-

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
        '/opt/local/lib/libreadline.dylib',
        '/usr/lib/libreadline.so',
        '/usr/local/lib/libreadline.so',
        File.join(Gem.bindir, 'readline.dll')
      ])
      dlload(pathes.find { |path| File.exist?(path)})
      extern 'int rl_refresh_line(int, int)'
    end
    def self.refresh_line
      LIBREADLINE.rl_refresh_line(0, 0)
    end
  rescue Exception
    def self.refresh_line;end
  end
end

def win?
  !!(RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|bccwin|cygwin/)
end

require 'highline'
def create_highline
  HighLine.track_eof = false
  if $stdin.respond_to?(:getbyte) # for ruby1.9
    def $stdin.getc; getbyte end
  end
  HighLine.new($stdin)
end
