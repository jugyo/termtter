module Termtter
  class CommandNotFound < StandardError; end

  module Client

    @@hooks = []
    @@commands = {}
    @@new_commands = {}
    @@completions = []
    @@filters = []
    @@helps = []

    class << self
      def public_storage
        @@public_storage ||= {}
      end

      %w[hook completion filter].each do |n|
        eval <<-EOF
          def add_#{n}(&b)
            @@#{n}s << b
          end
        EOF
      end

      def add_command(regex, &block)
        @@commands[regex] = block
      end

      def register_command(arg)
        command = case arg
          when Command
            arg
          when Hash
            Command.new(arg)
          else
            raise ArgumentError, 'must be given Termtter::Command or Hash'
          end
        @@new_commands[command.name] = command
      end

      def get_command(name)
        @@new_commands[name]
      end

      def add_macro(r, s)
        add_command(r) do |m, t|
          call_commands(s % m.to_a[1..-1])
        end
      end

      def add_help(name, desc)
        @@helps << [name, desc]
      end

      %w[hooks commands completions helps filters].each do |n|
        eval <<-EOF
          def clear_#{n}
            @@#{n}.clear
          end
        EOF
      end

      # memo: each filter must return Array of Status
      def apply_filters(statuses)
        filtered = statuses.map{|s| s.dup }
        @@filters.each do |f|
          filtered = f.call(filtered)
        end
        filtered
      rescue => e
        handle_error(e)
        statuses
      end

      def do_hooks(statuses, event)
        @@hooks.each do |h|
          begin
            h.call(statuses.dup, event, Termtter::API.twitter)
          rescue => e
            handle_error(e)
          end
        end
      end

      # TODO: delete argument "tw" when unnecessary
      def call_hooks(statuses, event, tw = nil)
        do_hooks(statuses, :pre_filter)
        do_hooks(apply_filters(statuses), event)
      end

      def call_commands(text, tw = nil)
        return if text.empty?

        command_found = false
        @@commands.each do |key, command|
          if key =~ text
            command_found = true
            begin
              command.call($~, Termtter::API.twitter)
            rescue => e
              handle_error(e)
            end
          end
        end

        @@new_commands.each do |key, command|
          command_info = command.match?(text)
          # TODO: call hook for before command here.
          if command_info
            command_found = true
            result = command.execute(command_info[1])
            if result
              # TODO: call hook for after command with result.
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
        call_hooks([], :exit)
        @@main_thread.kill
        @@update_thread.kill
        @@input_thread.kill
      end

      def load_default_plugins
        plugin 'standard_plugins'
        plugin 'stdout'
      end

      def load_config
        conf_file = File.expand_path('~/.termtter')
        if File.exist? conf_file
          wrap_require do
            load conf_file
          end
        else
          HighLine.track_eof = false
          ui = HighLine.new
          username = ui.ask('your twitter username: ')
          password = ui.ask('your twitter password: ') { |q| q.echo = false }

          File.open(File.expand_path('~/.termtter'), 'w') {|io|
            plugins = Dir.glob(File.dirname(__FILE__) + "/../lib/plugin/*.rb").map  {|f|
              f.match(%r|lib/plugin/(.*?).rb$|)[1]
            }
            plugins -= %w[stdout standard_plugins]
            plugins.each do |p|
              io.puts "#plugin '#{p}'"
            end

            io.puts
            io.puts "configatron.user_name = '#{username}'"
            io.puts "configatron.password = '#{password}'"
            io.puts "#configatron.update_interval = 120"
            io.puts "#configatron.proxy.host = 'proxy host'"
            io.puts "#configatron.proxy.port = '8080'"
            io.puts "#configatron.proxy.user_name = 'proxy user'"
            io.puts "#configatron.proxy.password = 'proxy password'"
            io.puts
            io.puts "# vim: set filetype=ruby"
          }
          puts "generated: ~/.termtter"
          puts "enjoy!"
          wrap_require do
            load conf_file
          end
        end
      end

      def setup_readline
        Readline.basic_word_break_characters= "\t\n\"\\'`><=;|&{("
        Readline.completion_proc = proc {|input|
          begin
            # FIXME: when migrate to Termtter::Command
            completions = @@completions.map {|completion|
              completion.call(input)
            }
            completions += @@new_commands.map {|name, command|
              command.complement(input)
            }
            completions.flatten.compact
          rescue => e
            handle_error(e)
          end
        }
        vi_or_emacs = configatron.editing_mode
        unless vi_or_emacs.empty?
          Readline.__send__("#{vi_or_emacs}_editing_mode")
        end
      end

      def setup_api()
        Termtter::API.setup()
      end

      def run
        load_default_plugins()
        load_config()
        setup_readline()
        setup_api()

        puts 'initializing...'
        initialized = false
        @@pause = false
        call_hooks([], :initialize)

        @@input_thread = nil
        @@update_thread = Thread.new do
          since_id = nil
          loop do
            begin
              Thread.stop if @@pause

              statuses = Termtter::API.twitter.get_friends_timeline(since_id)
              unless statuses.empty?
                since_id = statuses[0].id
              end
              print "\e[1K\e[0G" if !statuses.empty? && !win?
              call_hooks(statuses, :update_friends_timeline)
              initialized = true
              @@input_thread.kill if @@input_thread && !statuses.empty?
            rescue OpenURI::HTTPError => e
              if e.message == '401 Unauthorized'
                puts 'Could not login'
                puts 'plese check your account settings'
                exit!
              end
            ensure
              sleep configatron.update_interval
            end
          end
        end

        until initialized; end

        begin
          stty_save = `stty -g`.chomp
          trap("INT") { system "stty", stty_save; exit }
        rescue Errno::ENOENT
        end

        @@main_thread = Thread.new do
          loop do
            @@input_thread = create_input_thread()
            @@input_thread.join
          end
        end
        @@main_thread.join
      end

      def create_input_thread()
        Thread.new do
          erb = ERB.new(configatron.prompt)
          while buf = Readline.readline(erb.result(Termtter::API.twitter.__send__(:binding)), true)
            Readline::HISTORY.pop if /^(u|update)\s+(.+)$/ =~ buf
            begin
              call_commands(buf)
            rescue CommandNotFound => e
              puts "Unknown command \"#{buf}\""
              puts 'Enter "help" for instructions'
            end
          end
          exit # exit when press Control-D
        end
      end

      def wrap_require
        # FIXME: delete this method after the major version up
        alias original_require require
        def require(s)
          if %r|^termtter/(.*)| =~ s
            puts "[WARNING] use plugin '#{$1}' instead of require"
            puts "  Such a legacy .termtter file will not be supported until version 1.0.0"
            s = "plugin/#{$1}"
          end
          original_require s
        end
        yield
        alias require original_require
      end
      private :wrap_require
    end
  end
end

