# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

module Termtter

  describe Command do

    before do
      params =  {
          :name            => 'update',
          :aliases         => ['u', 'up'],
          :exec_proc       => lambda {|arg| arg },
          :completion_proc => lambda {|command, arg| ['complete1', 'complete2'] },
          :help            => ['update,u TEXT', 'test command']
      }
      @command = Command.new(params)
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
      [
        ['upd',       ['update']],
        [' upd',      []],
        [' upd ',     []],
        ['update a',    ['complete1', 'complete2']],
        [' update  ', []],
        ['u foo',     ['complete1', 'complete2']],
      ].each do |input, comp|
        @command.complement(input).should == comp
      end
    end

    it 'should return command_info when call method "match?"' do
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

    it 'should raise ArgumentError when constructor arguments are deficient' do
      lambda { Command.new }.should raise_error(ArgumentError)
      lambda { Command.new(:exec_proc => lambda {|args|}) }.should raise_error(ArgumentError)
      lambda { Command.new(:aliases => ['u']) }.should raise_error(ArgumentError)
    end

    it 'should call exec_proc when call method "call"' do
      @command.call('test').should == 'test'
      @command.call(' test').should == ' test'
      @command.call(' test ').should == ' test '
      @command.call('test test').should == 'test test'
    end

    it 'should raise ArgumentError at call' do
      lambda { @command.call(nil) }.should_not raise_error(ArgumentError)
      lambda { @command.call('foo') }.should_not raise_error(ArgumentError)
      lambda { @command.call(false) }.should raise_error(ArgumentError)
      lambda { @command.call(Array.new) }.should raise_error(ArgumentError)
    end

    it 'split command line' do
      Command.split_command_line('test foo bar').should == ['test', 'foo bar']
      Command.split_command_line('test   foo bar').should == ['test', 'foo bar']
      Command.split_command_line('test   foo  bar').should == ['test', 'foo  bar']
      Command.split_command_line(' test   foo  bar').should == ['test', 'foo  bar']
      Command.split_command_line(' test   foo  bar ').should == ['test', 'foo  bar']
    end
  end
end

