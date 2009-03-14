# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../../lib/termtter/config.rb'

module Termtter::Config

  describe Storage do

    before do
      @strage = Storage.new('config')
    end

    it 'should be add value to new strage' do
      @strage.new_strage = :value
      @strage.new_strage.should == :value
    end
  end
end
