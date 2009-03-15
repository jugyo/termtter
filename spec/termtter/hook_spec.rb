# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

module Termtter
  describe Hook do
    before do
    end

    it 'should match' do
      hook = Hook.new(
        :name => :span,
        :points => ['foo'],
        :exec_proc => lambda{|cmd, arg|
          puts 'a'
        }
      )
      hook.match?('foo').should == true
      hook.match?('bar').should == false
      hook.match?(:foo).should == true
      hook.match?(:bar).should == false
    end

    it 'should match when multi points' do
      hook = Hook.new(
        :name => :span,
        :points => ['foo', 'bar'],
        :exec_proc => lambda{|cmd, arg|
          puts 'a'
        }
      )
      hook.match?('foo').should == true
      hook.match?('bar').should == true
      hook.match?(:foo).should == true
      hook.match?(:bar).should == true
    end

    it 'should match when multi points' do
      hook = Hook.new(
        :name => :span,
        :points => ['foo', /bar/],
        :exec_proc => lambda{|cmd, arg|
          puts 'a'
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
        :name => :span,
        :points => ['foo', /^bar/],
        :exec_proc => lambda{|cmd, arg|
          puts 'a'
        }
      )
      hook.match?('bar').should == true
      hook.match?('bar_').should == true
      hook.match?('_bar_').should == false
      hook.match?(:'bar').should == true
      hook.match?(:'bar_').should == true
      hook.match?(:'_bar_').should == false
    end
  end
end
