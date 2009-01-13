require File.dirname(__FILE__) + '/../../lib/termtter'

module Termtter

  describe Command do
    
    before do
      @command = Command.new(
                  :name => 'update',
                  :aliases => ['u', 'up'],
                  :exec_proc => proc {|arg|
                    arg
                  },
                  :completion_proc => proc {|command, arg|
                    ['complete1', 'complete2']
                  },
                  :help => ['update,u TEXT', 'test command']
                )
    end

    it 'should execute' do
      result = @command.exec_if_match('update test test')
      result.should == 'test test'
      result = @command.exec_if_match('update   test test  ')
      result.should == 'test test'
      result = @command.exec_if_match('update test   test')
      result.should == 'test   test'
    end

    it 'should failed on execute' do
      result = @command.exec_if_match('upda test test')
      result.should == nil
    end

    it 'should return command regex' do
      @command.pattern.should == /^\s*((update|u|up)|(update|u|up)\s+(.*?))\s*$/
    end

    it 'should return commands' do
      @command.commands.should == ['update', 'u', 'up']
    end

    it 'should return help' do
      @command.help.should == ['update,u TEXT', 'test command']
    end

    it 'should return candidates for completion' do
      # complement
      @command.complement('upd').should == ['update']
      @command.complement(' upd').should == ['update']
      @command.complement(' upd ').should == ['update']
      @command.complement('upda').should == ['update']
      @command.complement('update').should == ['complete1', 'complete2']
      @command.complement('update ').should == ['complete1', 'complete2']
      @command.complement(' update  ').should == ['complete1', 'complete2']
      @command.complement('u foo').should == ['complete1', 'complete2']
      @command.complement('u').should == ['complete1', 'complete2']
      @command.complement('up').should == ['complete1', 'complete2']
    end
    
    it 'should can redefine exec_proc' do
      # redefine exec_proc
      command_arg = nil
      @command.exec_proc = proc {|arg|
        command_arg = arg
        'result'
      }
      command_arg.should == nil

      # exec command
      result = @command.exec_if_match('update test test')
      command_arg.should == 'test test'
      result.should == 'result'
    end

    it 'should return command_info when call method "match?"' do
      @command.match?('update').should == ['update', nil]
      @command.match?('up').should == ['up', nil]
      @command.match?('u').should == ['u', nil]
      @command.match?('update ').should == ['update', nil]
      @command.match?(' update ').should == ['update', nil]

      @command.match?('update foo').should == ['update', 'foo']
      @command.match?(' update foo').should == ['update', 'foo']
      @command.match?(' update foo ').should == ['update', 'foo']
      @command.match?('u foo').should == ['u', 'foo']
      @command.match?('up foo').should == ['up', 'foo']
      @command.match?('upd foo').should == nil
      @command.match?('upd foo').should == nil
    end

    it 'should raise ArgumentError when constructor arguments are deficient' do
      lambda {
        Command.new(:exec_proc => proc {|arg| })
      }.should raise_error(ArgumentError)
      lambda {
        Command.new(:name => 'update')
      }.should raise_error(ArgumentError)
    end
  end
end

