# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'

module Termtter
  describe MemoryCache do
    it 'is like Hash' do
      cache = MemoryCache.new(2)
      cache[:foo] = 'foo'
      cache[:bar] = 'bar'

      cache[:foo].should == 'foo'
      cache[:foo].should == 'foo'

      cache[:jugyo] = 'jugyo'
      cache[:jugyo].should == 'jugyo'

      cache.key?(:foo).should be_false
    end
  end
end
