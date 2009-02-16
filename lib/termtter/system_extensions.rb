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
     0 => 0x07|0x00|0x00|0x00, # black/white
    37 => 0x08|0x00|0x00|0x00, # white/intensity
    31 => 0x04|0x08|0x00|0x00, # red/red
    32 => 0x02|0x08|0x00|0x00, # green/green
    33 => 0x06|0x08|0x00|0x00, # yellow/yellow
    34 => 0x01|0x08|0x00|0x00, # blue/blue
    35 => 0x05|0x08|0x00|0x00, # magenta/purple
    36 => 0x03|0x08|0x00|0x00, # cyan/aqua
    39 => 0x07,                # default
    40 => 0x00|0x00|0xf0|0x00, # background:white
    41 => 0x07|0x00|0x40|0x00, # background:red
    42 => 0x07|0x00|0x20|0x00, # background:green
    43 => 0x07|0x00|0x60|0x00, # background:yellow
    44 => 0x07|0x00|0x10|0x00, # background:blue
    45 => 0x07|0x00|0x50|0x80, # background:magenta
    46 => 0x07|0x00|0x30|0x80, # background:cyan
    47 => 0x07|0x00|0x70|0x80, # background:gray
    49 => 0x70,                # default
    90 => 0x07|0x00|0x00|0x00, # erase/white
  }
  $iconv_u8_to_sj = Iconv.new("CP#{$wGetACP.call()}", 'UTF-8')
  def print(str)
    str.to_s.gsub("\xef\xbd\x9e", "\xe3\x80\x9c").split(/(\e\[\d*[a-zA-Z])/).each do |token|
      case token
      when /\e\[(\d+)m/
        $wSetConsoleTextAttribute.call $hStdOut, $colorMap[$1.to_i].to_i
	  when /\e\[\d*[a-zA-Z]/
        # do nothing
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
    $iconv_u8_to_sj.iconv(nil)
  end
  def puts(str)
    print str
    STDOUT.puts
  end
end
