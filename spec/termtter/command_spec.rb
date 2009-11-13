# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

module Termtter
  describe 'Command#initialize' do
    it 'requires the name element in the argument hash' do
      lambda { Command.new(:nama => 1) }.should raise_error(ArgumentError)
      lambda { Command.new(:name => 1) }.should_not raise_error(ArgumentError)
    end

    it 'does not destroy the argument hash' do
      hash = {
        :name => 1,
        :exec => 3
      }
      Command.new hash

      hash.should eql(hash)
      hash[:name].should == 1
      hash[:exec].should == 3
      hash[:exec_proc].should be_nil
    end
  end

  describe Command do
    before do
      params =  {
        :name            => 'update',
        :aliases         => ['u', 'up'],
        :exec_proc       => lambda {|arg| arg },
        :completion_proc => lambda {|command, arg| %w[complete1 complete2] },
        :help            => ['update,u TEXT', 'test command']
      }
      @command = Command.new(params)
    end

    describe '#pattern' do
      it 'returns command regex' do
        @command.pattern.
          should == /^((update|u|up)|(update|u|up)\s+(.*?))\s*$/
      end
    end

    it 'is given name as String or Symbol' do
      Command.new(:name => 'foo').name.should == :foo
      Command.new(:name => :foo).name.should == :foo
    end

    it 'returns name' do
      @command.name.should == :update
    end

    it 'returns aliases' do
      @command.aliases.should == [:u, :up]
    end

    it 'returns commands' do
      @command.commands.should == [:update, :u, :up]
    end

    it 'returns help' do
      @command.help.should == ['update,u TEXT', 'test command']
    end

    it 'returns candidates for completion' do
      # complement
      [
        ['upd',       ['update']],
        [' upd',      []],
        [' upd ',     []],
        ['update a',  ['complete1', 'complete2']],
        [' update  ', []],
        ['u foo',     ['complete1', 'complete2']],
      ].each do |input, comp|
        @command.complement(input).should == comp
      end
    end

    it 'returns command_info when call method "match?"' do
      [
        ['update',       true],
        ['up',           true],
        ['u',            true],
        ['update ',      true],
        [' update ',     false],
        ['update foo',   true],
        [' update foo',  false],
        [' update foo ', false],
        ['u foo',        true],
        ['up foo',       true],
        ['upd foo',      false],
        ['upd foo',      false],
      ].each do |input, result|
        @command.match?(input).should == result
      end
    end

    it 'calls exec_proc when call method "call"' do
      @command.call('foo', 'test', 'foo test').should == 'test'
      @command.call('foo', ' test', 'foo  test').should == ' test'
      @command.call('foo', ' test ', 'foo  test ').should == ' test '
      @command.call('foo', 'test test', 'foo test test').should == 'test test'
    end

    it 'raises ArgumentError at call' do
      lambda { @command.call('foo', nil, 'foo') }.
        should_not raise_error(ArgumentError)
      lambda { @command.call('foo', 'foo', 'foo') }.
        should_not raise_error(ArgumentError)
      lambda { @command.call('foo', false, 'foo') }.
        should raise_error(ArgumentError)
      lambda { @command.call('foo', Array.new, 'foo') }.
        should raise_error(ArgumentError)
    end

    describe '#alias=' do
      it 'wraps aliases=' do
        a = :ujihisa
        @command.should_receive(:aliases=).with([a])
        @command.alias = a
      end
    end

    describe 'spec for split_command_line' do
      before do
        @command = Command.new(:name => 'test')
      end

      it 'splits from a command line string to the command name and the arg' do
        @command.split_command_line('test').
          should == ['test', nil]
        @command.split_command_line('test foo bar').
          should == ['test', 'foo bar']
        @command.split_command_line('test   foo bar').
          should == ['test', 'foo bar']
        @command.split_command_line('test   foo  bar').
          should == ['test', 'foo  bar']
        @command.split_command_line(' test   foo  bar').
          should == ['test', 'foo  bar']
        @command.split_command_line(' test   foo  bar ').
          should == ['test', 'foo  bar']
      end

      describe 'spec for split_command_line with sub command' do
        before do
          @command = Command.new(:name => 'foo bar')
        end

        it 'splits from a command line string to the command name and the arg' do
          @command.split_command_line('foo bar args').
            should == ['foo bar', 'args']
          @command.split_command_line('foo  bar args').
            should == ['foo bar', 'args']
          @command.split_command_line(' foo  bar  args ').
            should == ['foo bar', 'args']
          @command.split_command_line(' foo  foo  args ').
            should == ['foo foo', 'args']
        end
      end
    end
  end
end
