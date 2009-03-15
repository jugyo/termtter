# -*- coding: utf-8 -*-

module Termtter
  class CommandNotFound < StandardError; end

  module Client

    class << self

      def init
        @@hooks = []
        @@new_hooks = {}
        @@new_commands = {}
        @@completions = []
        @@filters = []
        @@helps = []
        @@since_id = nil
        @@input_thread = nil
        @@task_manager = Termtter::TaskManager.new
        config.set_default(:update_interval, 300)
        config.set_default(:prompt, '> ')
        config.set_default(:devel, false)
        Thread.abort_on_exception = true
      end

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

      def register_hook(arg)
        hook = case arg
          when Hook
            arg
          when Hash
            Hook.new(arg)
          else
            raise ArgumentError, 'must be given Termtter::Hook or Hash'
          end
        @@new_hooks[hook.name] = hook
      end

      def get_hook(name)
        @@new_hooks[name]
      end

      def get_hooks(point)
        @@new_hooks.values.select do |hook|
          hook.match?(point)
        end
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

      def register_macro(name, macro, options = {})
        command = {
          :name => name.to_sym,
          :exec_proc => lambda {|arg| call_commands(macro % arg)}
        }.merge(options)
        register_command(command)
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
      def apply_filters(result, event = nil)
        case event
        when :show
          # nop
        when :search
          filtered = result.results.map(&:dup)
          @@filters.each do |f|
            filtered = f.call(filtered, event)
          end
          result.results = filtered
          result
        else
          filtered = result.map(&:dup)
          @@filters.each do |f|
            filtered = f.call(filtered, event)
          end
          filtered
        end
      rescue => e
        handle_error(e)
        result
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

      # return last hook return value
      def call_new_hooks(point, *args)
        result = nil
        get_hooks(point).each {|hook|
          break if result == false # interrupt if hook return false
          result = hook.exec_proc.call(*args)
        }
        result
      rescue => e
        if point.to_sym == :on_error
          raise
        else
          handle_error(e)
        end
      end

      # TODO: delete argument "tw" when unnecessary
      def call_hooks(statuses, event, tw = nil)
        do_hooks(statuses, :pre_filter)
        filtered = apply_filters(statuses, event)
        do_hooks(filtered, :post_filter)
        do_hooks(filtered, event)
      end

      def call_commands(text, tw = nil)
        return if text.empty?

        command_found = false
        @@new_commands.each do |key, command|
          command_str, command_arg = command.match?(text)
          if command_str
            command_found = true

            modified_arg = call_new_hooks(
                              "modify_arg_for_#{command.name.to_s}",
                              command_str,
                              command_arg) || command_arg || ''

            @@task_manager.invoke_and_wait do

              pre_exec_hook_result = call_new_hooks("pre_exec_#{command.name.to_s}", command_str, modified_arg)
              next if pre_exec_hook_result == false
              # exec command
              result = command.execute(modified_arg)
              if result
                call_new_hooks("post_exec_#{command.name.to_s}", command_str, modified_arg, result)
              end

            end
          end
        end

        raise CommandNotFound, text unless command_found
      end

      def pause
        @@task_manager.pause
      end

      def resume
        @@task_manager.resume
      end

      def add_task(*arg, &block)
        @@task_manager.add_task(*arg, &block)
      end

      def exit
        puts 'finalizing...'

        call_hooks([], :exit)
        call_new_hooks(:exit)
        @@task_manager.kill
        @@input_thread.kill if @@input_thread
      end

      def load_default_plugins
        plugin 'standard_plugins'
        plugin 'stdout'
      end

      def load_config
        legacy_config_support() if File.exist? Termtter::CONF_DIR
        if File.exist? Termtter::CONF_FILE
          load Termtter::CONF_FILE
        else
          ui = create_highline
          username = ui.ask('your twitter username: ')
          password = ui.ask('your twitter password: ') { |q| q.echo = false }

          Dir.mkdir(Termtter::CONF_DIR)
          File.open(Termtter::CONF_FILE, 'w') {|io|
            io.puts '# -*- coding: utf-8 -*-'

            plugins = Dir.glob(File.dirname(__FILE__) + "/../lib/plugins/*.rb").map  {|f|
              f.match(%r|lib/plugin/(.*?).rb$|)[1]
            }
            plugins -= %w[stdout standard_plugins]
            plugins.each do |p|
              io.puts "#plugin '#{p}'"
            end

            io.puts
            io.puts "config.user_name = '#{username}'"
            io.puts "config.password = '#{password}'"
            io.puts "#config.update_interval = 120"
            io.puts "#config.proxy.host = 'proxy host'"
            io.puts "#config.proxy.port = '8080'"
            io.puts "#config.proxy.user_name = 'proxy user'"
            io.puts "#config.proxy.password = 'proxy password'"
            io.puts
            io.puts "# vim: set filetype=ruby"
          }
          puts "generated: ~/.termtter/config"
          puts "enjoy!"
          load Termtter::CONF_FILE
        end
      end

      def legacy_config_support
        case File.ftype(File.expand_path('~/.termtter'))
        when 'directory'
          # nop
        when 'file'
          move_legacy_config_file
        end
      end

      def move_legacy_config_file
        FileUtils.mv(
          Termtter::CONF_DIR,
          File.expand_path('~/.termtter___'))
        Dir.mkdir(Termtter::CONF_DIR)
        FileUtils.mv(
          File.expand_path('~/.termtter___'),
          Termtter::CONF_FILE)
      end

      def pre_config_load()
        if config.devel
          plugin 'devel'
        end
      end

      def setup_readline
        if Readline.respond_to?(:basic_word_break_characters=)
          Readline.basic_word_break_characters= "\t\n\"\\'`><=;|&{("
        end
        Readline.completion_proc = lambda {|input|
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
        vi_or_emacs = config.editing_mode
        unless vi_or_emacs.empty?
          Readline.__send__("#{vi_or_emacs}_editing_mode")
        end
      end

      def setup_update_timeline_task()
        register_command(
          :name => :_update_timeline,
          :exec_proc => lambda {|arg|
            begin
              args = @@since_id ? [{:since_id => @@since_id}] : []
              statuses = Termtter::API.twitter.friends_timeline(*args)
              unless statuses.empty?
                @@since_id = statuses[0].id
              end
              call_hooks(statuses, :update_friends_timeline)
              statuses
            rescue OpenURI::HTTPError => e
              if e.message == '401 Unauthorized'
                puts 'Could not login'
                puts 'plese check your account settings'
                exit!
              end
            end
          }
        )

        add_task(:name => :update_timeline, :interval => config.update_interval) do
          call_commands('_update_timeline')
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
        rescue Errno::ENOENT
        end
      end

      def start_input_thread
        setup_readline()
        trap_setting()
        @@input_thread = Thread.new do
          while buf = Readline.readline(ERB.new(config.prompt).result(API.twitter.__send__(:binding)), true)
            Readline::HISTORY.pop if /^(u|update)\s+(.+)$/ =~ buf
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
        @@input_thread.join
      end

      def run
        require 'termtter/optparse'
        puts 'initializing...'

        load_default_plugins()
        load_config()
        Termtter::API.setup()
        pre_config_load()

        call_hooks([], :initialize)
        call_new_hooks(:initialize)

        setup_update_timeline_task()
        call_commands('_update_timeline')

        @@task_manager.run()
        start_input_thread()
      end

      def create_highline
        HighLine.track_eof = false
        if $stdin.respond_to?(:getbyte) # for ruby1.9
          require 'delegate'
          stdin_for_highline = SimpleDelegator.new($stdin)
          def stdin_for_highline.getc
            getbyte
          end
        else
          stdin_for_highline = $stdin
        end
        HighLine.new(stdin_for_highline)
      end

      def handle_error(e)
        call_new_hooks("on_error", e)
      rescue => e
        puts "Error: #{e}"
        puts e.backtrace.join("\n")
      end
    end
  end
end

Termtter::Client.init
