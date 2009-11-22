# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

module Termtter
  describe RubytterProxy do
    before do
      @rubytter_mock = Object.new
      Rubytter.stub!(:new).and_return(@rubytter_mock)
      @twitter = RubytterProxy.new('foo', 'bar', {})
    end

    it 'should call a Rubytter\'s method' do
      @rubytter_mock.should_receive(:update).with('test').once
      @twitter.update('test')
    end

    it 'should call a Rubytter\'s method with block' do
      block = Proc.new{}
      @rubytter_mock.should_receive(:update).with('test').once
      @twitter.update('test')
    end

    it 'should call hooks' do
      pre_hook = RubytterProxy.register_hook(:pre, :point => :pre_update) {}
      pre_hook.should_receive(:call).with('test')
      post_hook = RubytterProxy.register_hook(:post, :point => :post_update) {}
      post_hook.should_receive(:call).with('test')
      @rubytter_mock.stub!(:update)

      @twitter.update('test')
    end

    it 'should cancel to call method' do
      pre_hook = RubytterProxy.register_hook(:pre, :point => :pre_update) {raise HookCanceled}
      post_hook = RubytterProxy.register_hook(:post, :point => :post_update) {}
      post_hook.should_receive(:call).with('test').never
      @rubytter_mock.stub!(:update)

      @twitter.update('test')
    end
  end
end
