# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'

module Dummy
  include Termtter::Hookable
end

module Termtter
  describe Hookable do

    it 'takes new_hook' do
      hook = Hook.new(:name => :test)
      Dummy.register_hook(hook)
      Dummy.get_hook(:test).should == hook
    end

    it 'takes hook as Hash' do
      Dummy.register_hook(:name => :test)
      Dummy.get_hook(:test).name.should == :test
    end

    it 'calls new_hook' do
      hook_called = false
      Dummy.register_hook(:name => :test1, :points => [:point1], :exec_proc => lambda {hook_called = true})
      hook_called.should == false
      Dummy.call_hooks(:point1)
      hook_called.should == true
    end

    it 'calls new_hook with args' do
      arg1 = nil
      arg2 = nil
      Dummy.register_hook(:name => :test1, :points => [:point1], :exec_proc => lambda {|a1, a2| arg1 = a1; arg2 = a2})
      arg1.should == nil
      arg2.should == nil
      Dummy.call_hooks(:point1, 'foo', 'bar')
      arg1.should == 'foo'
      arg2.should == 'bar'
    end

    it 'return hooks when call get_hooks' do
      hook1 = Dummy.register_hook(:name => :test1, :points => [:point1])
      hook2 = Dummy.register_hook(:name => :test2, :points => [:point1])
      hook3 = Dummy.register_hook(:name => :test3, :points => [:point2])

      hooks = Dummy.get_hooks(:point1)
      hooks.size.should == 2
      hooks.include?(hook1).should == true
      hooks.include?(hook2).should == true
      hooks.include?(hook3).should == false
    end
  end
end
