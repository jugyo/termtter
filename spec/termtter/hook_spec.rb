# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

module Termtter
  describe Hook do
    before do
    end

    it 'should match' do
      hook = Hook.new(
        :name => :spam,
        :points => ['foo'],
        :exec_proc => lambda{|cmd, arg|
        }
      )
      hook.match?('foo').should == true
      hook.match?('bar').should == false
      hook.match?(:foo).should == true
      hook.match?(:bar).should == false
    end

    it 'should match when multi points' do
      hook = Hook.new(
        :name => :spam,
        :points => ['foo', 'bar'],
        :exec_proc => lambda{|cmd, arg|
        }
      )
      hook.match?('foo').should == true
      hook.match?('bar').should == true
      hook.match?(:foo).should == true
      hook.match?(:bar).should == true
    end

    it 'should match when multi points' do
      hook = Hook.new(
        :name => :spam,
        :points => ['foo', /bar/],
        :exec_proc => lambda{|cmd, arg|
        }
      )
      hook.match?('foo').should == true
      hook.match?('bar').should == true
      hook.match?('_bar_').should == true
      hook.match?(:foo).should == true
      hook.match?(:_bar_).should == true
    end

    it 'should match when multi points' do
      hook = Hook.new(
        :name => :spam,
        :points => ['foo', /^bar/],
        :exec_proc => lambda{|cmd, arg|
        }
      )
      hook.match?('bar').should == true
      hook.match?('bar_').should == true
      hook.match?('_bar_').should == false
      hook.match?(:'bar').should == true
      hook.match?(:'bar_').should == true
      hook.match?(:'_bar_').should == false
    end

    it 'should not match invalid point' do
      hook = Hook.new(
        :name => :spam,
        :points => [1, { }, nil],
        :exec_proc => lambda{|cmd, arg|
        }
        )
      hook.match?(1).should == false
      hook.match?({ }).should == false
      hook.match?(nil).should == false
    end

    it 'call hook proc' do
      proc_args = nil
      hook = Hook.new(
        :name => :spam,
        :points => ['foo'],
        :exec_proc => lambda{|*args|
          proc_args = args
        }
      )
      hook.call('foo', 'bar')
      proc_args.should == ['foo', 'bar']
    end
  end
end
