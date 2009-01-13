require File.dirname(__FILE__) + '/../../lib/termtter'

module Termtter
  describe Twitter, 'when initialize' do
    it '' do
      command_arg = nil
      command = Command.new(
                  :names => ['update', 'u'],
                  :exec => proc {|text|
                    command_arg = text
                  },
                  :completion => proc {|input|
                    ['test foo', 'test fooo', 'test bar'].grep(/^#{Regexp.quote(input)}/)
                  },
                  :help => ['update,u TEXT', 'test command']
                )

      command.names.should == ['update', 'u']
      command.pattern.should == /^(update|u)\s*(.*)/
      command.help.should == ['update,u TEXT', 'test command']
      command_arg.should == nil

      # complement
      command.complement('test').should == ['test foo', 'test fooo', 'test bar']
      command.complement('test foo').should == ['test foo', 'test fooo']
      command.complement('test fooo').should == ['test fooo']

      # exec command
      command.exec_if_match('update test')
      command_arg.should == 'test'

      # test to raise ArgumentError
      lambda{
        #command.exec_if_match('update')
        raise ArgumentError
      }.should raise_error(ArgumentError)

      # redefine command.proc
      $new_command_called = false
      def command.exec_proc
        proc {|text| $new_command_called = true }
      end
      $new_command_called.should == false
      command.exec_if_match('update test')
      $new_command_called.should == true
    end
  end
end
 
