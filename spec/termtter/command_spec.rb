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
      @command.pattern.should == /^((update|u|up)|(update|u|up)\s+(.*?))\s*$/
    end

    it 'should be given name as String or Symbol' do
      Command.new(:name => 'foo').name.should == :foo
      Command.new(:name => :foo).name.should == :foo
    end

    it 'should return name' do
      @command.name.should == :update
    end

    it 'should return aliases' do
      @command.aliases.should == [:u, :up]
    end

    it 'should return commands' do
      @command.commands.should == [:update, :u, :up]
    end

    it 'should return help' do
      @command.help.should == ['update,u TEXT', 'test command']
    end

    it 'should return candidates for completion' do
      # complement
      @command.complement('upd').should == ['update']
      @command.complement(' upd').should == []
      @command.complement(' upd ').should == []
      @command.complement('upda').should == ['update']
      @command.complement('update').should == ['complete1', 'complete2']
      @command.complement('update ').should == ['complete1', 'complete2']
      @command.complement(' update  ').should == []
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
      @command.match?(' update ').should == nil

      @command.match?('update foo').should == ['update', 'foo']
      @command.match?(' update foo').should == nil
      @command.match?(' update foo ').should == nil
      @command.match?('u foo').should == ['u', 'foo']
      @command.match?('up foo').should == ['up', 'foo']
      @command.match?('upd foo').should == nil
      @command.match?('upd foo').should == nil
    end

    it 'should raise ArgumentError when constructor arguments are deficient' do
      lambda { Command.new }.should raise_error(ArgumentError)
      lambda { Command.new(:exec_proc => proc {|args|}) }.should raise_error(ArgumentError)
      lambda { Command.new(:aliases => ['u']) }.should raise_error(ArgumentError)
    end

    it 'should return true with the exec_proc return nil' do
      command = Command.new(:name => :test, :exec_proc => proc {|args|})
      command.exec_if_match('test').should == true
    end

    it 'should call exec_proc when call method "execute"' do
      @command.execute('test').should == 'test'
      @command.execute(' test').should == ' test'
      @command.execute(' test ').should == ' test '
      @command.execute('test test').should == 'test test'
    end

    it 'should redefine method "exec_if_match"' do
      # add method
      class << @command
        def exec_if_match(input)
          case input
          when /^update\s+foo\s*(.*)/
            foo($1)
          when /^update\s+bar\s*(.*)/
            bar($1)
          end
        end
        def foo(arg)
          "foo(#{arg})"
        end
        def bar(arg)
          "bar(#{arg})"
        end
      end

      @command.exec_if_match('update foo xxx').should == 'foo(xxx)'
      @command.exec_if_match('update bar xxx').should == 'bar(xxx)'
    end
  end
end

