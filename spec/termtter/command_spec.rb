require File.dirname(__FILE__) + '/../../lib/termtter'

module Termtter
  describe Twitter, 'when initialize' do
    it '' do
      command_arg1 = nil
      command_arg2 = nil
      command = Command.new(
                  :names => ['update', 'u'],
                  :exec => proc {|args|
                    command_arg1 = args[0]
                    command_arg2 = args[1]
                  },
                  :completion => proc {|input|
                    ['test foo', 'test fooo', 'test bar'].grep(/^#{Regexp.quote(input)}/)
                  },
                  :help => ['update,u TEXT', 'test command']
                )

      command.names.should == ['update', 'u']
      command.pattern.should == /^(update|u)\s*(.*)/
      command.help.should == ['update,u TEXT', 'test command']
      command_arg1.should == nil
      command_arg2.should == nil

      # complement
      command.complement('test').should == ['test foo', 'test fooo', 'test bar']
      command.complement('test foo').should == ['test foo', 'test fooo']
      command.complement('test fooo').should == ['test fooo']

      # exec command
      command.exec_if_match('update arg1 arg2')
      command_arg1.should == 'arg1'
      command_arg2.should == 'arg2'

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
 
