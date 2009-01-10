module Termtter
  class CommandNotFound < StandardError; end
  module Client

    @@hooks = []
    @@commands = {}
    @@completions = []
    @@filters = []
    @@helps = []

    class << self
      def public_storage
        @@public_storage ||= {}
      end

      def add_hook(&hook)
        @@hooks << hook
      end

      def clear_hooks
        @@hooks.clear
      end

      def add_command(regex, &block)
        @@commands[regex] = block
      end

      def add_macro(r, s)
        add_command(r) do |m, t|
          call_commands(s % m.to_a[1..-1], t)
        end
      end

      def clear_commands
        @@commands.clear
      end

      def add_completion(&completion)
        @@completions << completion
      end

      def clear_completions
        @@completions.clear
      end

      def add_help(name, desc)
        @@helps << [name, desc]
      end

      def clear_helps
        @@helps.clear
      end

      def add_filter(&filter)
        @@filters << filter
      end

      def clear_filters
        @@filters.clear
      end

      # memo: each filter must return Array of Status
      def apply_filters(statuses)
        filtered = statuses.map{|s| s.dup }
        @@filters.each do |f|
          filtered = f.call(filtered)
        end
        filtered
      rescue => e
        puts "Error: #{e}"
        puts e.backtrace.join("\n")
        statuses
      end

      Readline.basic_word_break_characters= "\t\n\"\\'`><=;|&{("
      Readline.completion_proc = proc {|input|
        @@completions.map {|completion|
          completion.call(input)
        }.flatten.compact
      }

      def do_hooks(statuses, event, tw)
        @@hooks.each do |h|
          begin
            h.call(statuses.dup, event, tw)
          rescue => e
            puts "Error: #{e}"
            puts e.backtrace.join("\n")
          end
        end
      end
      
      def call_hooks(statuses, event, tw)
        do_hooks(statuses, :pre_filter, tw)
        do_hooks(apply_filters(statuses), event, tw)
      end

      def call_commands(text, tw)
        return if text.empty?

        command_found = false
        @@commands.each do |key, command|
          if key =~ text
            command_found = true
            begin
              command.call($~, tw)
            rescue => e
              puts "Error: #{e}"
              puts e.backtrace.join("\n")
            end
          end
        end

        raise CommandNotFound unless command_found
      end

      def pause
        @@pause = true
      end

      def resume
        @@pause = false
        @@update_thread.run
      end

      def exit
        call_hooks([], :exit, nil)
        @@main_thread.kill
        @@update_thread.kill
        @@input_thread.kill
      end

      def run
        puts 'initializing...'
        initialized = false
        @@pause = false
        tw = Termtter::Twitter.new(configatron.user_name, configatron.password)
        call_hooks([], :initialize, tw)

        @@input_thread = nil
        @@update_thread = Thread.new do
          since_id = nil
          loop do
            begin
              Thread.stop if @@pause

              statuses = tw.get_friends_timeline(since_id)
              unless statuses.empty?
                since_id = statuses[0].id
              end
              print "\e[1K\e[0G" if !statuses.empty? && !win?
              call_hooks(statuses, :update_friends_timeline, tw)
              initialized = true
              @@input_thread.kill if @@input_thread && !statuses.empty?
            rescue OpenURI::HTTPError => e
              if e.message == '401 Unauthorized'
                puts 'Could not login'
                puts 'plese check your account settings'
                exit!
              end
            rescue => e
              puts "Error: #{e}"
              puts e.backtrace.join("\n")
            ensure
              sleep configatron.update_interval
            end
          end
        end

        until initialized; end

        vi_or_emacs = configatron.editing_mode
        unless vi_or_emacs.empty?
          Readline.__send__("#{vi_or_emacs}_editing_mode")
        end

        begin
          stty_save = `stty -g`.chomp
          trap("INT") { system "stty", stty_save; exit }
        rescue Errno::ENOENT
        end

        @@main_thread = Thread.new do
          loop do
            @@input_thread = create_input_thread(tw)
            @@input_thread.join
          end
        end
        @@main_thread.join
      end

      def create_input_thread(tw)
        Thread.new do
          erb = ERB.new(configatron.prompt)
          while buf = Readline.readline(erb.result(tw.__send__(:binding)), true)
            Readline::HISTORY.pop if /^(u|update)\s+(.+)$/ =~ buf
            begin
              call_commands(buf, tw)
            rescue CommandNotFound => e
              puts "Unknown command \"#{buf}\""
              puts 'Enter "help" for instructions'
            rescue => e
              puts "Error: #{e}"
              puts e.backtrace.join("\n")
            end
          end
          exit # exit when press Control-D
        end
      end
    end
  end
end

