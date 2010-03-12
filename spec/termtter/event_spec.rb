# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'
require 'termtter/event'

module Termtter
  describe Event do

    it 'creates with name' do
      event = Event.new(:foo)
      event.should be_kind_of Event
    end

    it 'in not created with wrong arguments' do
      lambda{ Event.new }.should raise_error
      lambda{ Event.new(1) }.should raise_error
      lambda{ Event.new('hello') }.should raise_error
      lambda{ Event.new('hello', 'goodbye') }.should raise_error
      lambda{ Event.new(:hello, :goodbye) }.should raise_error
    end

    it 'bes created with name and params' do
      event = Event.new(:bar, :a => 'alpha', :b => 'bravo')
      event.should be_kind_of Event
    end

    it 'has name' do
      event = Event.new(:foo)
      event.name.should == :foo
    end

    it 'compares with symbol' do
      event = Event.new(:foo)
      event.should == :foo
      :foo.should == event
    end

    it 'compares with itself' do
      event = Event.new(:foo)
      event.should == event
    end

    it 'compares with other events' do
      a = Event.new(:foo)
      b1 = Event.new(:bar)
      b2 = Event.new(:bar, :a => 'alpha', :b => 'bravo')
      a.should_not == b1
      a.should_not == b2
      b1.should == b2
    end

    it 'compares with other objects' do
      event = Event.new(:foo)
      event.should_not == 'hello'
      event.should_not == 33
    end

    it 'compares with symbol using case' do
      event = Event.new(:foo)
      matched =
        case event
        when :foo
          :foo_matched
        else
          :not_matched
        end
      matched.should == :foo_matched

      matched =
        case :foo
        when event
          :foo_matched
        else
          :not_matched
        end
      matched.should == :foo_matched
    end

    it 'delegates to ActiveRubytter' do
      event = Event.new(:bar, :a => 'alpha', :b => 'bravo')
      event.a.should == 'alpha'
      event.b.should == 'bravo'
      lambda { event.c }.should raise_error(NoMethodError)
      event[:a].should == 'alpha'
      event[:b].should == 'bravo'
      event[:c].should be_nil

      event.to_hash.should == {:a => 'alpha', :b => 'bravo'}

      lambda {
        event.attributes = {:c => 'charlie', :d => 'delta'}
      }.should_not raise_error

      event.to_hash.should == {:c => 'charlie', :d => 'delta'}
    end

    it 'delegates to Symbol' do
      a = Event.new(:foo, :a => 'alpha', :b => 'bravo')
      a.to_sym.should == a.name.to_sym
      a.id2name.should == a.name.id2name
      a.to_s.should == a.name.to_s

      # NOTE: Isn't this spec working?
      #a.to_i.should == a.name.to_i
    end

    it 'provides has_key?' do
      event = Event.new(:foo, :a => 'alpha', :b => 'bravo')
      event.has_key?(:a).should be_true
      event.has_key?(:b).should be_true
      event.has_key?(:c).should be_false
    end

    it 'provides []= ' do
      event = Event.new(:foo)
      event[:a] = 'alpha'
      event.a.should == 'alpha'
    end
  end
end
