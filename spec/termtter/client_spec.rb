# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

module Termtter
  describe Client do
    before do
      Client.clear_filter
      Client.clear_command
      Client.setup_logger
    end

    # FIXME: Depends recent implement
    it 'can run' do
      Client.should_receive(:load_config) {}
      Termtter::API.should_receive(:setup) {}
      Client.should_receive(:setup_logger) {}
      Client.should_receive(:load_plugins) {}
      Client.should_receive(:eval_init_block) {}

      config.system.eval_scripts = []
      config.system.cmd_mode = true
      Client.run
    end

    it 'can run (eval script cannot eval)' do
      Client.stub(:load_config) {}
      Termtter::API.stub(:setup) {}
      Client.stub(:setup_logger) {}
      Client.stub(:load_plugins) {}
      Client.stub(:eval_init_block) {}

      config.system.eval_scripts = ['raise']
      Client.should_receive(:handle_error)

      config.system.cmd_mode = true
      Client.run
    end

    it 'can run (eval script cannot eval)' do
      Client.stub(:load_config) {}
      Termtter::API.stub(:setup) {}
      Client.stub(:setup_logger) {}
      Client.stub(:load_plugins) {}
      Client.stub(:eval_init_block) {}

      config.system.eval_scripts = []
      config.system.cmd_mode = false
      Client.instance_variable_get(:@task_manager).should_receive(:run) {}
      Client.should_receive(:call_hooks).with(:initialize)
      Client.should_receive(:call_hooks).with(:launched)
      Client.run
    end

    it 'set init block' do
      dummy = lambda {}
      Client.init(&dummy)
      Client.instance_variable_get(:@init_block).should == dummy
    end

    it 'can run init block' do
      Client.init() {}
      Client.instance_variable_get(:@init_block).
        should_receive(:call).with(Client)
      Client.eval_init_block
    end

    it 'can load plugins when initializing stage (normal)' do
      config.devel = false
      Client.should_receive(:plug).exactly(2).times
      Client.load_plugins
    end

    it 'can load plugins when initializing stage (devel)' do
      Client.should_receive(:plug).exactly(2).times
      Client.load_plugins
    end

    it 'can pause and resume' do
      manager = Client.instance_variable_get(:@task_manager)
      manager.should_receive(:pause)
      Client.pause
      manager.should_receive(:resume)
      Client.resume
    end

    it 'takes command' do
      command = Command.new(:name => :test)
      Client.register_command(command)
      Client.get_command(:test).should == command
    end

    it 'takes command as Hash' do
      Client.register_command(:name => :test)
      Client.get_command(:test).name.should == :test
    end

    it 'takes register_command as block' do
      process = lambda {}
      Client.register_command('test', &process)
      command = Client.get_command(:test)
      command.name.should == :test
      command.exec_proc.should == process
    end

    it 'takes register_command as block with options' do
      process = lambda {}
      Client.register_command('test', :help => 'help', &process)
      command = Client.get_command(:test)
      command.name.should == :test
      command.exec_proc.should == process
      command.help.should == 'help'
    end

    it 'takes register command as block with symbol name' do
      lambda {
        Client.register_command(:name) {}
      }.should_not raise_error
    end

    it 'register_command can raise error when take invalid argument' do
      [1, ['hoge', 'fuga'], nil, Object.new].each do |bad|
        lambda {
          Client.register_command(bad)
        }.should raise_error(ArgumentError)
      end
    end


    it 'takes add_command as block' do
      Client.add_command('test') do |c|
        c.aliases = ['t']
        c.help = 'test command is a test'
      end
      command = Client.get_command(:test)
      command.name.should == :test
      command.aliases.should == [:t]
      command.help.should == 'test command is a test'
    end

    it 'takes add_command as block without past config' do
      Client.add_command('past') do |c|
        c.help = 'past help'
      end
      Client.get_command(:past).help.should == 'past help'
      Client.add_command('new') {}
      Client.get_command(:new).help.should_not == 'past help'
    end

    it 'raises ArgumentError when call add_command without block' do
      lambda { Client.add_command('past') }.should raise_error(ArgumentError)
    end

    it 'calls command' do
      command_arg = nil
      command = Command.new(:name => :test, :exec_proc => lambda {|arg| command_arg = arg})
      Client.register_command(command)
      command_arg.should == nil

      [
        ['test',            ''],
        ['test foo bar',    'foo bar'],
        ['test  foo bar ',  'foo bar'],
        ['test  foo  bar ', 'foo  bar'],
      ].each do |input, args|
        status = Client.call_commands(input)
        command_arg.should == args
        status.should == 0
      end
    end

    it 'takes new_hook' do
      hook = Hook.new(:name => :test)
      Client.register_hook(hook)
      Client.get_hook(:test).should == hook
    end

    it 'takes hook as Hash' do
      Client.register_hook(:name => :test)
      Client.get_hook(:test).name.should == :test
    end

    it 'calls new_hook' do
      hook_called = false
      Client.register_hook(:name => :test1, :points => [:point1], :exec_proc => lambda {hook_called = true})
      hook_called.should == false
      Client.call_hooks(:point1)
      hook_called.should == true
    end

    it 'register_hook can raise error when take invalid argument' do
      [1, ['hoge', 'fuga'], nil, Object.new].each do |bad|
        lambda {
          Client.register_hook(bad)
        }.should raise_error(ArgumentError)
      end
    end

    it 'calls new_hook with args' do
      arg1 = nil
      arg2 = nil
      Client.register_hook(:name => :test1, :points => [:point1], :exec_proc => lambda {|a1, a2| arg1 = a1; arg2 = a2})
      arg1.should == nil
      arg2.should == nil
      Client.call_hooks(:point1, 'foo', 'bar')
      arg1.should == 'foo'
      arg2.should == 'bar'
    end

    it 'return hooks when call get_hooks' do
      hook1 = Client.register_hook(:name => :test1, :points => [:point1])
      hook2 = Client.register_hook(:name => :test2, :points => [:point1])
      hook3 = Client.register_hook(:name => :test3, :points => [:point2])

      hooks = Client.get_hooks(:point1)
      hooks.size.should == 2
      hooks.include?(hook1).should == true
      hooks.include?(hook2).should == true
      hooks.include?(hook3).should == false
    end

    it 'calls decide_arg hooks' do
      input_command = nil
      input_arg = nil
      decided_arg = nil
      Client.register_hook( :name => :test1,
                            :points => [:modify_arg_for_update],
                            :exec_proc => lambda {|cmd, arg| input_command = cmd; input_arg = arg; arg.upcase})
      Client.register_hook( :name => :test2,
                            :points => [:pre_exec_update],
                            :exec_proc => lambda {|cmd, arg| decided_arg = arg})
      Client.register_command(:name => :update, :aliases => [:u], :exec => lambda{|arg|})

      input_command.should == nil
      input_arg.should == nil
      decided_arg.should == nil
      Client.call_commands('u foo')
      input_command.should == 'u'
      input_arg.should == 'foo'
      decided_arg.should == 'FOO'
    end

    it 'calls pre_command hooks' do
      hook_called = false
      Client.register_hook( :name => :test,
                            :points => [:pre_command],
                            :exec_proc => lambda {|text| hook_called = true; text})
      Client.register_command(:name => :update, :exec => lambda{|arg|})

      hook_called.should == false
      Client.call_commands('')
      hook_called.should == true

      hook_called = false
      Client.call_commands('update foo')
      hook_called.should == true
    end

    it 'calls post_command hooks' do
      hook_called = false
      Client.register_hook( :name => :test,
                            :points => [:post_command],
                            :exec_proc => lambda {|text| hook_called = true})
      Client.register_command(:name => :update, :exec => lambda{|arg|})

      hook_called.should == false
      Client.call_commands('')
      hook_called.should == false

      Client.call_commands('update foo')
      hook_called.should == true
    end

    it 'calls pre_exec hooks' do
      hook_called = false
      Client.register_hook( :name => :test,
                            :points => [:pre_exec_update],
                            :exec_proc => lambda {|cmd, arg| hook_called = true})
      Client.register_command(:name => :update, :exec => lambda{|arg|})

      hook_called.should == false
      Client.call_commands('update foo')
      hook_called.should == true
    end

    it 'able to cancel exec command' do
      command_called = false
      Client.register_hook( :name => :test,
                            :points => [:pre_exec_update],
                            :exec_proc => lambda {|cmd, arg| raise CommandCanceled})
      Client.register_command(:name => :update, :exec_proc => lambda {|arg| command_called = true})

      command_called.should == false
      Client.call_commands('update foo')
      command_called.should == false
    end

    it 'calls post_exec hooks' do
      command_result = nil
      Client.register_hook( :name => :test,
                            :points => [:post_exec_update],
                            :exec_proc => lambda {|cmd, arg, result| command_result = result })
      Client.register_command(:name => :update, :exec_proc => lambda {|arg| 'foo'})

      command_result.should == nil
      Client.call_commands('update foo')
      command_result.should == 'foo'
    end

    it 'calls exit hooks' do
      hook_called = false
      Client.register_hook(
        :name => :test,
        :points => [:exit],
        :exec_proc => lambda { hook_called = true }
      )

      hook_called.should == false
      Client.should_receive(:puts)
      Client.instance_variable_get(:@task_manager).
        should_receive(:kill) {}
      Client.exit
      hook_called.should == true
    end

    it 'calls plural hooks' do
      hook1_called = false
      hook2_called = false
      Client.register_hook(:name => :hook1, :points => [:exit], :exec_proc => lambda {hook1_called = true})
      Client.register_hook(:name => :hook2, :points => [:exit], :exec_proc => lambda {hook2_called = true})

      hook1_called.should == false
      hook2_called.should == false
      Client.instance_variable_get(:@task_manager).stub(:kill)
      Client.should_receive(:puts)
      Client.exit
      hook1_called.should == true
      hook2_called.should == true
    end

    it 'is able to override hooks' do
      hook1_called = false
      hook2_called = false
      Client.register_hook(:name => :hook, :points => [:exit], :exec_proc => lambda {hook1_called = true})
      Client.register_hook(:name => :hook, :points => [:exit], :exec_proc => lambda {hook2_called = true})

      hook1_called.should == false
      hook2_called.should == false
      Client.should_receive(:puts)
      Client.exit
      hook1_called.should == false
      hook2_called.should == true
    end

    it 'takes register_hook as block' do
      process = lambda {}
      Client.register_hook('test', &process)
      hook = Client.get_hook(:test)
      hook.name.should == :test
      hook.exec_proc.should == process
    end

    it 'takes register_hook as block with options' do
      process = lambda {}
      Client.register_hook('test', :point => :foo, &process)
      hook = Client.get_hook(:test)
      hook.name.should == :test
      hook.exec_proc.should == process
      hook.points.should == [:foo]
    end

    it 'takes register hook as block with symbol name' do
      lambda {
        Client.register_hook(:name) {}
      }.should_not raise_error
    end

    it 'can apply filter' do
      statuses = [
        { :id => 2,
          :created_at => Time.now,
          :user_id => 2,
          :name => 'name',
          :screen_name => 'screen name',
          :source => 'termtter',
          :reply_to => 1,
          :text => 'hi',
          :original_data => 'hi' }
      ]
      event     = :output_for_test
      hook_name = :my_hook

      hook = Client.register_hook(hook_name) {|s, e| s.text.should == 'hi'; e.should == event }
      hook.should_receive(:call)
      Client.should_receive(:get_hooks).with(hook_name).and_return([hook])
      Client.apply_filters_for_hook(hook_name, statuses, event)
    end

    it 'can add macro' do
      Client.should_receive(:register_command).
        with {|arg| arg.should be_an_instance_of(Hash) }
      Client.register_macro('greet', "update %s")
    end

    it 'can load config' do
      Client.should_receive(:load).with(Termtter::CONF_FILE)
      Client.load_config
    end

    it 'can create config file when load_config' do
      File.should_receive(:exist?).twice.and_return(false)
      require 'termtter/config_setup'
      ConfigSetup.should_receive(:run).and_return(false)
      Client.stub(:load).with(Termtter::CONF_FILE)
      Client.load_config
    end

    it 'can output status (bad)' do
      Client.should_not_receive(:call_hooks)
      Client.output(nil, :hoge)
      Client.should_not_receive(:call_hooks)
      Client.output([], :hoge)
    end

    # FIXME: too dirty
    it 'can output status (good)' do
      statuses = mock('statuses', :null_object => true)
      statuses.stub(:empty? => false, :nil? => false)
      event = :event
      Client.should_receive(:call_hooks).with(:pre_filter, statuses, event)
      Client.should_receive(:apply_filters_for_hook).exactly(2).times.
        with(an_instance_of(Symbol), anything, event).
        and_return(statuses)
      Client.should_receive(:call_hooks).with(:post_filter, statuses, event)
      hook = mock(:hook, :name => 'test')
      hook.should_receive(:call).with(anything, event)
      Client.should_receive(:get_hooks).with(:output).and_return([hook])
      Client.output(statuses, event)
    end

    it 'handles error' do
      logger = Client.instance_variable_get(:@logger)
      logger.should_receive(:error).with("StandardError: error")
      Client.handle_error StandardError.new('error')
    end

    it 'handle_error raise error when logger is nothing' do
      Client.instance_variable_set(:@logger, nil)
      $stderr, old = StringIO.new, $stderr
      Client.handle_error(StandardError.new('error'))
      $stderr.rewind
      $stderr.gets.should match(/\AError: error/)
      $stderr = old
    end

    it 'cancels command by hook' do
      command = Command.new(:name => :test)
      Client.register_command(command)
      Client.register_hook(
        :name => :test,
        :point => /^pre_exec/,
        :exec => lambda{|*arg|
            raise Termtter::CommandCanceled
        }
      )
      command.should_not_receive(:call)
      Client.call_commands('test')
    end

    it 'gets default help' do
      Client.plug 'defaults' # FIXME: Do not need
      $stdout, old_stdout = StringIO.new, $stdout # FIXME That suspends any debug informations!
      help_command = Client.get_command(:help)
      help_command.should_not be_nil
      help_command.call
      $stdout.string.should_not == '' # 何がか出力されていること
      $stdout = old_stdout
    end

    it 'gets an added help' do
      Client.plug 'defaults' # FIXME: Do not need
      Client.register_command(
        :name => :foo,
        :help => [
          ['foo USER', 'foo to USER'],
          ['foo list', 'list foo'],
        ]
      )
      $stdout, old_stdout = StringIO.new, $stdout # FIXME That suspends any debug informations!
      help_command = Client.get_command(:help)
      help_command.should_not be_nil
      help_command.call
      $stdout.string.should match(/foo USER/)
      $stdout.string.should match(/foo list/)
    end

    it 'can confirm before update (yes default)' do
      message = 'hello'
      Readline.should_receive(:readline).
        with("\"#{message}".strip + "\" [Y/n] ", false)
      Client.confirm(message)
    end

    it 'can confirm before update (no default)' do
      message = 'hello'
      Readline.should_receive(:readline).
        with("\"#{message}".strip + "\" [N/y] ", false)
      Client.confirm(message, false)
    end

    it 'can configm before update' do
      ok_pattern = [ 'y', 'Y', '' ]
      ng_pattern = [
        'n', 'N',
        ('a'..'z').to_a,
        ('A'..'Z').to_a ].flatten
      ng_pattern -= ['y', 'Y']

      ok_pattern.each do |ask|
        Readline.should_receive(:readline).and_return(ask)
        Client.confirm('hello').should be_true
      end
      ng_pattern.each do |ask|
        Readline.should_receive(:readline).and_return(ask)
        Client.confirm('hello').should be_false
      end
    end

    it 'confirm can take block as callback' do
      Readline.stub(:readline => 'y')
      called = false
      Client.confirm('hello') { called = true }
      called.should be_true
    end

    it 'default logger can cahnge error to fit security level' do
      logger = Client.default_logger
      TermColor.should_receive(:parse).with(match(/blue/))
      logger.debug 'hi'
      TermColor.should_receive(:parse).with(match(/cyan/))
      logger.info 'hi'
      TermColor.should_receive(:parse).with(match(/magenta/))
      logger.warn 'hi'
      TermColor.should_receive(:parse).with(match(/red/))
      logger.error 'hi'
      TermColor.should_receive(:parse).with(match(/on_red/))
      logger.fatal 'hi'
      TermColor.should_receive(:parse).with(match(/white/))
      logger.unknown 'hi'
    end

    it 'can cancel command' do
      text = 'text'
      command = mock('command', :null_object => true)
      command.stub(:call) { raise CommandCanceled }
      Client.stub(:find_commands).with(text).and_return([command])
      lambda {
        Client.call_commands(text).should == 1
      }.should_not raise_error
    end

    describe 'add commands' do
      before(:each) do
        Client.clear_command
        Client.register_command(:name => :foo1)
        Client.register_command(:name => :foo2)
        Client.register_command(:name => :bar)
      end

      it 'commands number is 3' do
        Client.commands.size.should == 3
      end

      it 'finds a command' do
        Client.find_commands('foo1').size.should == 1
        Client.find_commands('foo1')[0].name.should == :foo1
        Client.find_commands('bar').size.should == 1
      end

      it 'check command exists' do
        Client.command_exists?('foo').should == false
        Client.command_exists?('foo1').should == true
        Client.command_exists?('bar').should == true
        Client.command_exists?('foo1 bar').should == true
      end

      it 'finds no command' do
        Client.find_commands('foo').size.should == 0
      end
    end

    describe 'clear commands' do
      before(:each) do
        Client.clear_command
      end

      it 'no command' do
        Client.commands.size.should == 0
      end
    end

    describe '.plug' do
      it 'loads a plugin' do
        Client.should_receive(:load).with('plugins/aaa.rb')
        Client.plug 'aaa'
      end

      it 'loads a plugin with plugin name as Symbol' do
        Client.should_receive(:load).with('plugins/aaa.rb')
        Client.plug :aaa
      end

      it 'loads plugins' do
        Client.should_receive(:load).with('plugins/aaa.rb')
        Client.should_receive(:load).with('plugins/bbb.rb')
        Client.should_receive(:load).with('plugins/ccc.rb')
        Client.plug ['aaa', 'bbb', 'ccc']
      end
    end
  end
end
