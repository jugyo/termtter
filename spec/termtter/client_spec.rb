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
      command = Command.new(:name => :test, :exec_proc => lambda {|arg| command_arg = arg || 'nil'})
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
      Client.register_hook(:name => :test1, :points => [:point1], :exec_proc => proc {hook_called = true})
      hook_called.should == false
      Client.call_new_hooks(:point1)
      hook_called.should == true
    end

    it 'should call new_hook with args' do
      arg1 = nil
      arg2 = nil
      Client.register_hook(:name => :test1, :points => [:point1], :exec_proc => proc {|a1, a2| arg1 = a1; arg2 = a2})
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
                            :points => [:decide_arg_for_update],
                            :exec_proc => proc {|cmd, arg| input_command = cmd; input_arg = arg; arg.upcase})
      Client.register_hook( :name => :test2,
                            :points => [:pre_exec_update],
                            :exec_proc => proc {|cmd, arg| decided_arg = arg})
      Client.register_command(:name => :update, :aliases => [:u])

      input_command.should == nil
      input_arg.should == nil
      Client.call_commands('u foo')
      input_command.should == 'u'
      input_arg.should == 'foo'
      p decided_arg
    end
  end
end
