# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'

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
      pre_hook.should_receive(:call).with('test').and_return(["TEST"])
      post_hook = RubytterProxy.register_hook(:post, :point => :post_update) {}
      post_hook.should_receive(:call).with('test')
      @rubytter_mock.should_receive(:update).with("TEST")

      @twitter.update('test')
    end

    it 'should cancel to call method' do
      pre_hook = RubytterProxy.register_hook(:pre, :point => :pre_update) {raise HookCanceled}
      post_hook = RubytterProxy.register_hook(:post, :point => :post_update) {}
      post_hook.should_receive(:call).with('test').never
      @rubytter_mock.should_receive(:update).never

      @twitter.update('test')
    end

    it 'should retry to be success' do
      config.retry = 3
      @rubytter_mock.stub!(:update).exactly(1).times
      @twitter.update('test')
    end

    it 'should retry when raise TimeoutError' do
      config.retry = 3
      @rubytter_mock.stub!(:update).exactly(config.retry).times.and_raise(TimeoutError)
      @twitter.update('test')
    end

    it 'should store cache when call "show"' do
      status = "status"
      @rubytter_mock.should_receive(:show).exactly(1).and_return(status)
      @twitter.should_receive(:store_status_cache).with(status)
      @twitter.show(1)
    end

    it 'should store cache when call "home_timeline"' do
      statuses = ["1", "2"]
      @rubytter_mock.should_receive(:home_timeline).exactly(1).and_return(statuses)
      @twitter.should_receive(:store_status_cache).exactly(2)
      @twitter.home_timeline
    end

    it 'should store cache when call "store_status_cache"' do
      user = "user"
      @twitter.should_receive(:store_user_cache).with(user)
      @twitter.store_status_cache(ActiveRubytter.new({:user => user}))
    end

    it 'should not call rubytter if cache exists' do
      @twitter.status_cache_store[1] = "status"
      @rubytter_mock.should_receive(:show).exactly(0)
      @twitter.show(1).should == "status"
    end

    it 'has safe mode' do
      safe_twitter = @twitter.safe
      safe_twitter.should be_kind_of(RubytterProxy)
      safe_twitter.safe_mode.should be_true
      safe_twitter.rubytter.should == @twitter.rubytter
    end

    it 'dies when LimitManager.safe? is false' do
      safe_twitter = @twitter.safe
      safe_twitter.current_limit.stub!(:safe?).and_return(false)

      lambda{ safe_twitter.call_rubytter(:update, 'test') }.should raise_error(Termtter::RubytterProxy::FrequentAccessError)
    end
  end
end
