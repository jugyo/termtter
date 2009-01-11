require File.dirname(__FILE__) + '/../../lib/termtter'

module Termtter
  describe Twitter, 'when initialize' do
    it '' do
      command_called = false
      command = Command.new(
                  :names => ['test', 't'],
                  :pattern => /^(update|u)\s+(.*)/,
                  :exec => proc {|match|
                    command_called = true
                  },
                  :completion => proc {|input|
                    ['test foo', 'test fooo', 'test bar'].grep(/^#{Regexp.quote(input)}/)
                  },
                  :help => 'test command'
                )

      command.names.should == ['test', 't']
      command.pattern.should == /^(update|u)\s+(.*)/
      command.help.should == 'test command'
      command_called.should == false

      # complement
      command.complement('test').should == ['test foo', 'test fooo', 'test bar']
      command.complement('test foo').should == ['test foo', 'test fooo']
      command.complement('test fooo').should == ['test fooo']

      # exec command
      command.exec_if_match('update test')
      command_called.should == true

      # redefine command.proc
      $new_command_called = false
      def command.exec
        proc {|match| $new_command_called = true }
      end
      $new_command_called.should == false
      command.exec_if_match('update test')
      $new_command_called.should == true
    end
  end
end
 
