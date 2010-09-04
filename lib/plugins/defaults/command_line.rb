# -*- coding: utf-8 -*-
require 'singleton'

module Termtter
  class CommandLine
    include Singleton

    class << self
      def start
        instance.start
      end

      def stop
        instance.stop
      end
    end

    def start
      start_input_thread
    end

    def stop
      @input_thread.kill if @input_thread
    end

    def call(command_text)
      # Example:
      # t.register_hook(:post_all, :point => :prepare_command) do |s|
      #   "update #{s}"
      # end
      Client.get_hooks('prepare_command').each {|hook|
        command_text = hook.call(command_text)
      }
      Client.execute(command_text)
    rescue CommandNotFound => e
      hooks = Client.get_hooks('command_not_found')
      raise e if hooks.empty?
      hooks.each {|hook|
        hook.call(command_text)
      }
    rescue TimeoutError
      puts TermColor.parse("<red>Time out :(</red>")
    end

    def prompt
      prompt_text = config.prompt
      Client.get_hooks('prepare_prompt').each {|hook|
        prompt_text = hook.call(prompt_text)
      }
      prompt_text
    end

    private

    def start_input_thread
      setup_readline()
      trap_setting()
      @input_thread = Thread.new do
        while buf = Readline.readline(ERB.new(prompt).result(Termtter::API.twitter.__send__(:binding)), true)
          Readline::HISTORY.pop if buf.empty?
          begin
            call(buf)
          rescue Exception => e
            Client.handle_error(e)
          end
        end
        Client.exit
      end
      @input_thread.join
    end

    def do_completion(input)
      input = input.sub(/^\s*/, '')

      words = []

      words = Client.commands.values.
                inject([]) {|array, command| array + [command.name] + command.aliases}.
                map(&:to_s).
                grep(/^\s*#{Regexp.quote(input)}/)

      if words.empty?
        command = Client.find_command(input)
        words = command ? command.complement(input) : []
      end

      if words.empty?
        Client.get_hooks(:completion).each do |hook|
          words << hook.call(input) rescue nil
        end
      end

      words.flatten.compact
    rescue Exception => e
      Client.handle_error(e)
    end

    def setup_readline
      if Readline.respond_to?(:basic_word_break_characters=)
        Readline.basic_word_break_characters= "\t\n\"\\'`><=;|&{("
      end

      Readline.completion_case_fold = true

      Readline.completion_proc = lambda {|input| do_completion(input) }

      vi_or_emacs = config.editing_mode
      unless vi_or_emacs.empty?
        Readline.__send__("#{vi_or_emacs}_editing_mode")
      end

      Readline.rl_parse_and_bind('TAB: menu-complete')
    end

    def trap_setting()
      return if /mswin(?!ce)|mingw|bccwin/ =~ RUBY_PLATFORM

      begin
        stty_save = `stty -g`.chomp
        trap("INT") do
          begin
            system "stty", stty_save
          ensure
            Client.execute('exit')
          end
        end
        trap("CONT") do
          Readline.refresh_line
        end
        trap_sigwinch
      rescue ArgumentError
      rescue Errno::ENOENT
      end
    end

    # for Ruby 1.9.2(or later)'s Readline
    # TODO: support other platforms (like Mac OS X)
    if Readline.respond_to?(:set_screen_size) && /linux/ =~ RUBY_PLATFORM
      TIOCGWINSZ = 0x5413         # in Linux

      def trap_sigwinch
        trap('WINCH') do
          dat = ''
          STDOUT.ioctl(TIOCGWINSZ, dat)
          rows, cols = dat.unpack('S!4')
          Readline.set_screen_size(rows, cols)
          ENV['COLUMNS'] = cols.to_s
        end
      end
    else
      def trap_sigwinch; end
    end
  end

  Client.register_hook(:initialize_command_line, :point => :init_command_line) do
    CommandLine.start
  end

  Client.register_hook(:finalize_command_line, :point => :exit) do
    CommandLine.stop
  end

  Client.register_command(:vi_editing_mode) do |arg|
    Readline.vi_editing_mode
  end

  Client.register_command(:emacs_editing_mode) do |arg|
    Readline.emacs_editing_mode
  end
end
