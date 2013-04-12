# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'

module Termtter
  describe MemoryCache do
    it 'is like Hash' do
      cache = MemoryCache.new
      cache[:foo] = 'foo'
      cache[:bar] = 'bar'

      cache[:foo].should == 'foo'
      cache[:bar].should == 'bar'

      cache[:jugyo] = 'jugyo'
      cache[:jugyo].should == 'jugyo'

      cache.key?(:foo).should be_true
      cache.key?(:bar).should be_true
      cache.key?(:hoge).should be_false
    end
  end
end
