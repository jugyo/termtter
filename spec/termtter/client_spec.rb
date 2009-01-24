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
        ['test',            'nil'],
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
  end
end

