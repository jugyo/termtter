# -*- coding: utf-8 -*-
require 'fileutils'
require 'logger'

module Termtter
  APP_NAME = 'termtter'

  config.system.set_default :conf_dir, File.expand_path('~/.termtter')
  CONF_DIR = config.system.conf_dir

  config.system.set_default :conf_file, CONF_DIR + '/config'
  CONF_FILE = config.system.conf_file
  $:.unshift(Termtter::CONF_DIR)

  class CommandNotFound < StandardError; end

  module Client

    class << self

      def init
        @hooks = []
        @new_hooks = {}
        @new_commands = {}
        @completions = []
        @filters = []
        @helps = []
        @since_id = nil
        @input_thread = nil
        @task_manager = Termtter::TaskManager.new
        config.log.set_default(:logger, nil)
        config.log.set_default(:level, nil)
        config.set_default(:update_interval, 300)
        config.set_default(:prompt, '> ')
        config.set_default(:devel, false)
        Thread.abort_on_exception = true
      end

      def public_storage
        @public_storage ||= {}
      end

      %w[hook completion filter].each do |n|
        eval <<-EOF
          def add_#{n}(&b)
            @#{n}s << b
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
        @new_hooks[hook.name] = hook
      end

      def get_hook(name)
        @new_hooks[name]
      end

      def get_hooks(point)
        @new_hooks.values.select do |hook|
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
        @new_commands[command.name] = command
      end

      def get_command(name)
        @new_commands[name]
      end

      def register_macro(name, macro, options = {})
        command = {
          :name => name.to_sym,
          :exec_proc => lambda {|arg| call_commands(macro % arg)}
        }.merge(options)
        register_command(command)
      end

      def add_help(name, desc)
        @helps << [name, desc]
      end

      %w[hooks completions helps filters].each do |n|
        eval <<-EOF
          def clear_#{n}
            @#{n}.clear
          end
        EOF
      end

      # statuses => [status, status, ...]
      # status => {
      #             :id => status id,
      #             :created_at => created time,
      #             :user_id => user id,
      #             :name => user name,
      #             :screen_name => user screen_name,
      #             :source => source,
      #             :reply_to => reply_to status id,
      #             :text => status,
      #             :original_data => original data,
      #           }
      def output(statuses, event)
        statuses = statuses.sort_by{|s|s[:id]}
        # MEMO: event をいちいち渡さなくてもいいかもしれないなぁ
        call_new_hooks(:pre_filter, statuses, event)
        filtered = apply_filters(statuses, event)
        call_new_hooks(:post_filter, filtered, event)
        call_new_hooks(:output, filtered, event)
      end

      def apply_filters(statuses, event)
          filtered = statuses.map(&:dup)
          @filters.each do |f|
            filtered = f.call(filtered, event)
          end
          filtered
        rescue => e
          handle_error(e)
      end

      def do_hooks(statuses, event)
        @hooks.each do |h|
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
          result = hook.execute(*args)
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
        @new_commands.each do |key, command|
          # match? メソッドがなんかきもちわるいので変える予定
          command_str, command_arg = command.match?(text)
          if command_str
            command_found = true

            modified_arg = call_new_hooks(
                              "modify_arg_for_#{command.name.to_s}",
                              command_str,
                              command_arg) || command_arg || ''

            @task_manager.invoke_and_wait do

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
        @task_manager.pause
      end

      def resume
        @task_manager.resume
      end

      def add_task(*arg, &block)
        @task_manager.add_task(*arg, &block)
      end

      def exit
        puts 'finalizing...'

        call_hooks([], :exit)
        call_new_hooks(:exit)
        @task_manager.kill
        @input_thread.kill if @input_thread
      end

      def load_default_plugins
        plugin 'standard_plugins'
        plugin 'stdout'
      end

      def load_config
        legacy_config_support() if File.exist? Termtter::CONF_DIR
        unless File.exist?(Termtter::CONF_FILE)
          require 'termtter/config_setup'
          ConfigSetup.run
        end
        load Termtter::CONF_FILE
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

      def post_config_load()
        if config.system.devel
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
            completions = @completions.map {|completion|
              completion.call(input)
            }
            completions += @new_commands.map {|name, command|
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

      # TODO: Make pluggable
      def setup_update_timeline_task()
        register_command(
          :name => :_update_timeline,
          :exec_proc => lambda {|arg|
            begin
              args = @since_id ? [{:since_id => @since_id}] : []
              statuses = Termtter::API.twitter.friends_timeline(*args)
              unless statuses.empty?
                @since_id = statuses[0].id
                output(statuses_to_hash(statuses), :update_friends_timeline)
                Readline.refresh_line
              end
            rescue OpenURI::HTTPError => e
              if e.message == '401 Unauthorized'
                puts 'Could not login'
                puts 'plese check your account settings'
                exit!
              end
            end
          }
        )

        add_task(:name => :update_timeline, :interval => config.update_interval, :after => config.update_interval) do
          call_commands('_update_timeline')
        end

        call_commands('_update_timeline')
      end

      def statuses_to_hash(statuses)
        statuses.map do |s|
          {
            :id => s.id,
            :created_at => s.created_at,
            :user_id => s.user.id,
            :name => s.user.name,
            :screen_name => s.user.screen_name,
            :source => s.source,
            :in_reply_to_status_id => s.in_reply_to_status_id,
            :in_reply_to_user_id => s.in_reply_to_user_id,
            :post_text => s.text,
            :original_data => s
          }
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
        @input_thread = Thread.new do
          while buf = Readline.readline(ERB.new(config.prompt).result(API.twitter.__send__(:binding)), true)
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

      def logger
        @logger
      end

      def setup_logger
        @logger = config.log.logger || Logger.new(STDOUT)
        @logger.level = config.log.level || Logger::WARN
      end

      def run
        load_default_plugins()
        load_config()
        Termtter::API.setup()
        setup_logger()
        post_config_load()

        call_hooks([], :initialize)
        call_new_hooks(:initialize)

        setup_update_timeline_task()

        @task_manager.run()
        start_input_thread()
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
