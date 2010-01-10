# -*- coding: utf-8 -*-

config.plugins.another_prompt.
  set_default(:shortcut_setting,
              { ':' => '',
                'd' => 'direct',
                'D' => 'delete',
                'f' => 'fib',
                'F' => 'favorite',
                'l' => 'list',
                'o' => 'open',
                'p' => 'profile',
                'R' => 'reply',
                's' => 'search',
                't' => 'retweet',
                'u' => 'update',
                'c' => lambda do
                  system('clear')
                end,
                'L' => lambda do
                  puts '-' *
                    `stty size`.chomp.
                    sub(/^\d+\s(\d+)$/, '\\1').to_i
                end,
                'q' => lambda do
                  Termtter::Client.execute('quit')
                end,
                'r' => lambda do
                  Termtter::Client.execute('replies')
                end,
                '?' => lambda do
                  Termtter::Client.execute('help')
                end,
                "\e" => lambda do
                  system('screen', '-X', 'eval', 'copy')
                end
              })

Termtter::Client.plug 'curry'

module Termtter::Client
  add_task(:name => :auto_reload,
           :interval => config.update_interval,
           :after => config.update_interval) do
    begin
      execute('reload')
    rescue Exception => e
      handle_error(e)
    end
  end

  register_hook(
    :name => :auto_reload_init,
    :point => :initialize,
    :exec => lambda {
      begin
        execute('reload')
      rescue Exception => e
        handle_error(e)
      end
    }
  )
end

module Termtter
  class CommandLine
    include Singleton

    STTY_ORIGIN = `stty -g`.chomp

    def start_input_thread
      setup_readline()
      trap_setting()
      @input_thread = Thread.new do
        loop do
          begin
            value = config.plugins.another_prompt.shortcut_setting[wait_keypress]
            Client.pause
            case value
            when String
              call_prompt(value)
            when Proc
              value.call
            end
          ensure
            Client.resume
          end
        end
      end
      @input_thread.join
    end

    def call_prompt(command)
      Client.execute("curry #{command}")
      if buf = Readline.readline(ERB.new(prompt).result(Termtter::API.twitter.__send__(:binding)), true)
        Readline::HISTORY.pop if buf.empty?
        begin
          call(buf)
        rescue Exception => e
          Client.handle_error(e)
        end
      else
        puts
      end
    ensure
      Client.execute('uncurry')
    end

    def wait_keypress
      system('stty', '-echo', '-icanon')
      c = STDIN.getc
      return [c].pack('c')
    ensure
      system('stty', STTY_ORIGIN)
    end

    def trap_setting()
      begin
        trap("INT") do
          begin
            system "stty", STTY_ORIGIN
          ensure
            Client.execute('exit')
          end
        end
      rescue ArgumentError
      rescue Errno::ENOENT
      end
    end
  end
end
