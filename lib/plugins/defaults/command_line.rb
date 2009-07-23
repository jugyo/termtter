# -*- coding: utf-8 -*-
module Termtter::Client
  class << self
    def setup_readline
      if Readline.respond_to?(:basic_word_break_characters=)
        Readline.basic_word_break_characters= "\t\n\"\\'`><=;|&{("
      end
      Readline.completion_proc = lambda {|input|
        begin
          words = []
          words << @commands.map {|name, command| command.complement(input) }
          get_hooks(:completion).each do |hook|
            words << hook.call(input) rescue nil
          end
          words.flatten.compact
        rescue => e
          handle_error(e)
        end
      }
      vi_or_emacs = config.editing_mode
      unless vi_or_emacs.empty?
        Readline.__send__("#{vi_or_emacs}_editing_mode")
      end
    end

    def trap_setting()
      begin
        stty_save = `stty -g`.chomp
        trap("INT") do
          begin
            system "stty", stty_save
          ensure
            exit
          end
        end
        trap("CONT") do
          Readline.refresh_line
        end
      rescue ArgumentError
      rescue Errno::ENOENT
      end
    end

    def start_input_thread
      setup_readline()
      trap_setting()
      @input_thread = Thread.new do
        while buf = Readline.readline(ERB.new(config.prompt).result(Termtter::API.twitter.__send__(:binding)), true)
          Readline::HISTORY.pop if buf.empty?
          begin
            call_commands(buf)
          rescue CommandNotFound => e
            warn "Unknown command \"#{e}\""
            warn 'Enter "help" for instructions'
          rescue => e
            handle_error e
          end
        end
      end
      @input_thread.join
    end
  end

  register_hook(:initialize_command_line, :point => :launched) do
      start_input_thread
  end

  register_hook(:finalize_command_line, :point => :exit) do
    @input_thread.kill
  end
end
