# -*- coding: utf-8 -*-

module Termtter
  class CommandNotFound < StandardError; end

  module Client

    class << self

      def init
        @@hooks = []
        @@new_hooks = {}
        @@commands = {}
        @@new_commands = {}
        @@completions = []
        @@filters = []
        @@helps = []
        @@since_id = nil
        @@main_thread = nil
        @@input_thread = nil
        @@task_manager = Termtter::TaskManager.new
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

      # Deprecated
      # FIXME: delete when become unnecessary
      def add_command(regex, &block)
        warn "Termtter:Client.add_command method will be removed. Use Termtter::Client.register_command() instead. (#{caller.first})"
        @@commands[regex] = block
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

      # return last hook return value
      def call_new_hooks(point, *args)
        result = nil
        get_hooks(point).each {|hook|
          break if result == false # interrupt if hook return false
          result = hook.exec_proc.call(*args)
        }
        return result
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
        do_hooks(apply_filters(statuses), event)
      end

      def call_commands(text, tw = nil)
        return if text.empty?

        command_found = false
        @@commands.each do |key, command|
          if key =~ text
            command_found = true
            @@task_manager.invoke_and_wait do
              command.call($~, Termtter::API.twitter)
            end
          end
        end

        @@new_commands.each do |key, command|
          command_info = command.match?(text)
          if command_info
            command_found = true
            input_command, arg = *command_info

            modified_arg = call_new_hooks("modify_arg_for_#{command.name.to_s}", input_command, arg) || arg || ''

            @@task_manager.invoke_and_wait do
              pre_exec_hook_result = call_new_hooks("pre_exec_#{command.name.to_s}", input_command, modified_arg)
              next if pre_exec_hook_result == false

              # exec command
              result = command.execute(modified_arg)
              if result
                call_new_hooks("post_exec_#{command.name.to_s}", input_command, modified_arg, result)
              end
            end
          end
        end

        raise CommandNotFound unless command_found
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
        @@main_thread.kill if @@main_thread
        @@input_thread.kill if @@input_thread
      end

      def load_default_plugins
        plugin 'standard_plugins'
        plugin 'stdout'
        configatron.set_default(:devel, false)
        if configatron.devel
          plugin 'devel'
        end
      end

      def load_config
        conf_file = File.expand_path('~/.termtter')
        if File.exist? conf_file
          wrap_require do
            load conf_file
          end
        else
          ui = create_highline
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

      def setup_update_timeline_task()
        register_command(
          :name => :_update_timeline,
          :exec_proc => lambda {|arg|
            begin
              statuses = Termtter::API.twitter.get_friends_timeline(@@since_id)
              unless statuses.empty?
                @@since_id = statuses[0].id
              end
              print "\e[1K\e[0G" if !statuses.empty? && !win?
              call_hooks(statuses, :update_friends_timeline)
              @@input_thread.kill if @@input_thread && !statuses.empty?
            rescue OpenURI::HTTPError => e
              if e.message == '401 Unauthorized'
                puts 'Could not login'
                puts 'plese check your account settings'
                exit!
              end
            end
          }
        )

        add_task(:name => :update_timeline, :interval => configatron.update_interval) do
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
        trap_setting()
        @@main_thread = Thread.new do
          loop do
            @@input_thread = create_input_thread()
            @@input_thread.join
          end
        end
        @@main_thread.join
      end

      def run
        puts 'initializing...'

        load_default_plugins()
        load_config()
        Termtter::API.setup()

        call_hooks([], :initialize)
        call_new_hooks(:initialize)

        setup_update_timeline_task()
        call_commands('_update_timeline')

        @@task_manager.run()

        @input_thread = Thread.new do
          editor = RawLine::Editor.new
          editor.bind(:ctrl_l) { editor.clear_line }
          editor.completion_proc = lambda {|input|
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

          while line = editor.read("> ")
            begin
              line.chomp!
              call_commands(line)
            rescue CommandNotFound => e
              puts "Unknown command \"#{line}\""
              puts 'Enter "help" for instructions'
            end
          end
        end
        @input_thread.join
        #start_input_thread()
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
        return HighLine.new(stdin_for_highline)
      end

      def handle_error(e)
        call_new_hooks("on_error", e)
      rescue => e
        puts "Error: #{e}"
        puts e.backtrace.join("\n")
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

Termtter::Client.init
