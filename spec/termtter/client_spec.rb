require File.dirname(__FILE__) + '/../../lib/termtter'

module Termtter
  describe Client do
    it 'should take new_command' do
      command = Command.new(:name => :test)
      Client.add_new_command(command)
      Client.get_new_command(:test).should == command
    end

    it 'should call new_command' do
      command_arg = nil
      command = Command.new(:name => :test, :exec_proc => proc {|arg| command_arg = arg || 'nil'})
      Client.add_new_command(command)

      command_arg.should == nil
      Client.call_commands('test', nil)
      command_arg.should == 'nil'
      Client.call_commands('test foo bar', nil)
      command_arg.should == 'foo bar'
      Client.call_commands('test  foo bar ', nil)
      command_arg.should == 'foo bar'
      Client.call_commands('test  foo  bar ', nil)
      command_arg.should == 'foo  bar'
    end
  end
end

