# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

module Termtter

  describe Client do

    it 'should take new_command' do
      command = Command.new(:name => :test)
      Client.register_command(command)
      Client.get_command(:test).should == command
    end

    it 'should take command as Hash' do
      Client.register_command(:name => :test)
      Client.get_command(:test).name.should == :test
    end

    it 'should call new_command' do
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
        Client.call_commands(input, nil)
        command_arg.should == args
      end
    end

    it 'should take new_hook' do
      hook = Hook.new(:name => :test)
      Client.register_hook(hook)
      Client.get_hook(:test).should == hook
    end

    it 'should take hook as Hash' do
      Client.register_hook(:name => :test)
      Client.get_hook(:test).name.should == :test
    end

    it 'should call new_hook' do
      hook_called = false
      Client.register_hook(:name => :test1, :points => [:point1], :exec_proc => lambda {hook_called = true})
      hook_called.should == false
      Client.call_new_hooks(:point1)
      hook_called.should == true
    end

    it 'should call new_hook with args' do
      arg1 = nil
      arg2 = nil
      Client.register_hook(:name => :test1, :points => [:point1], :exec_proc => lambda {|a1, a2| arg1 = a1; arg2 = a2})
      arg1.should == nil
      arg2.should == nil
      Client.call_new_hooks(:point1, 'foo', 'bar')
      arg1.should == 'foo'
      arg2.should == 'bar'
    end

    it 'should return hooks when call get_hooks' do
      hook1 = Client.register_hook(:name => :test1, :points => [:point1])
      hook2 = Client.register_hook(:name => :test2, :points => [:point1])
      hook3 = Client.register_hook(:name => :test3, :points => [:point2])

      hooks = Client.get_hooks(:point1)
      hooks.size.should == 2
      hooks.include?(hook1).should == true
      hooks.include?(hook2).should == true
      hooks.include?(hook3).should == false
    end

    it 'should call decide_arg hooks' do
      input_command = nil
      input_arg = nil
      decided_arg = nil
      Client.register_hook( :name => :test1,
                            :points => [:modify_arg_for_update],
                            :exec_proc => lambda {|cmd, arg| input_command = cmd; input_arg = arg; arg.upcase})
      Client.register_hook( :name => :test2,
                            :points => [:pre_exec_update],
                            :exec_proc => lambda {|cmd, arg| decided_arg = arg})
      Client.register_command(:name => :update, :aliases => [:u])

      input_command.should == nil
      input_arg.should == nil
      decided_arg.should == nil
      Client.call_commands('u foo')
      input_command.should == 'u'
      input_arg.should == 'foo'
      decided_arg.should == 'FOO'
    end

    it 'should call pre_exec hooks' do
      hook_called = false
      Client.register_hook( :name => :test,
                            :points => [:pre_exec_update],
                            :exec_proc => lambda {|cmd, arg| hook_called = true})
      Client.register_command(:name => :update)

      hook_called.should == false
      Client.call_commands('update foo')
      hook_called.should == true
    end

    it 'should able to cancel exec command' do
      command_called = false
      Client.register_hook( :name => :test,
                            :points => [:pre_exec_update],
                            :exec_proc => lambda {|cmd, arg| false})
      Client.register_command(:name => :update, :exec_proc => lambda {|cmd, arg| command_called = true})

      command_called.should == false
      Client.call_commands('update foo')
      command_called.should == false
    end

    it 'should call post_exec hooks' do
      command_result = nil
      Client.register_hook( :name => :test,
                            :points => [:post_exec_update],
                            :exec_proc => lambda {|cmd, arg, result| command_result = result })
      Client.register_command(:name => :update, :exec_proc => lambda {|arg| 'foo'})

      command_result.should == nil
      Client.call_commands('update foo')
      command_result.should == 'foo'
    end

    it 'should call exit hooks' do
      hook_called = false
      Client.register_hook(
        :name => :test,
        :points => [:exit],
        :exec_proc => lambda { hook_called = true }
      )

      hook_called.should == false
      Client.should_receive(:puts)
      Client.exit
      hook_called.should == true
    end

    it 'should call plural hooks' do
      hook1_called = false
      hook2_called = false
      Client.register_hook(:name => :hook1, :points => [:exit], :exec_proc => lambda {hook1_called = true})
      Client.register_hook(:name => :hook2, :points => [:exit], :exec_proc => lambda {hook2_called = true})

      hook1_called.should == false
      hook2_called.should == false
      Client.should_receive(:puts)
      Client.exit
      hook1_called.should == true
      hook2_called.should == true
    end

    it 'should be able to override hooks' do
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

    it 'run' do
      Client.should_receive(:puts)
      Client.should_receive(:load_default_plugins)
      Client.should_receive(:load_config)
      Termtter::API.should_receive(:setup)
      Client.should_receive(:pre_config_load)
      Client.should_receive(:call_hooks)
      Client.should_receive(:call_new_hooks)
      Client.should_receive(:setup_update_timeline_task)
      Client.should_receive(:call_commands)
      Client.should_receive(:start_input_thread)
      Client.run
    end

    it 'should do nothing when ~/.termtter is directory' do
      File.should_receive(:ftype).and_return('directory')
      Client.should_not_receive(:move_legacy_config_file)
      Client.legacy_config_support
    end

    it 'should do "move_legacy_config_file" when ~/.termtter is file' do
      File.should_receive(:ftype).and_return('file')
      Client.should_receive(:move_legacy_config_file)
      Client.legacy_config_support
    end

    it 'should move legacy config file' do
      File.should_receive(:mv).twice
      Dir.should_receive(:mkdir)
      Client.move_legacy_config_file
    end
  end
end
