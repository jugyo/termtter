module Termtter
  module OptParser
    class << self
      def parse!(argv)
        @optionparser.parse!(argv)
      end
    end

    @optionparser = OptionParser.new { |opt|
      opt.program_name = 'Termtter'

      opt.on('-f', '--config-file file', 'Set path to configfile') do |val|
        config.system.__assign__(:conf_file, val)
      end

      opt.on('-t', '--termtter-directory directory', 'Set termtter directory') do |val|
        config.system.__assign__(:conf_dir, val)
      end

      opt.on('-d', '--devel', 'Start in developer mode') do |flg|
        config.__assign__(:devel, true) if flg
      end

      opt.on('-c', '--command-mode', 'Run as command mode') do |flg|
        config.system.cmd_mode = flg
      end

      opt.on('-r', '--run-command command', 'Run command') do |cmd|
        config.system.run_commands << cmd
      end

      opt.on('-p', '--plugin plugin', 'Load plugin') do |plugin|
        config.system.load_plugins << plugin
      end

      opt.on('-n', '--disable-plugin plugin', 'Disable plugin') do |plugin|
        config.system.disable_plugins << plugin
      end

      opt.on('-e', '--eval-script script', 'Eval script') do |script|
        config.system.eval_scripts << script
      end

      opt.on('-m', '--monochrome', 'No shell escapes for color highlightings') do |script|
        require 'termcolor'
        module ::TermColor
          class << self
            alias parse_orig parse
            def parse(o)
              o.gsub(/<.+?>(.*?)<\/.+?>/, '\1')
            end
          end
        end
      end

      opt.on('-u', '--user user', 'Login username') do |val|
        config.user_name = val
      end

      opt.version = Termtter::VERSION
    }
  end
end

