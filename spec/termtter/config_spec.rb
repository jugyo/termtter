# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

module Termtter::Config

  describe Storage do

    before do
      @storage = Storage.new('config')
    end

    it 'should be able to store value to new storage' do
      @storage.new_storage = :value
      @storage.new_storage.should == :value
    end

    it 'should be able to make sub.key and store value' do
      @storage.sub.key = :value
      @storage.sub.key.should == :value
    end

    it 'should be able to make multiple storage' do
      @storage.sub.more.for.test = 'value'
      @storage.sub.more.for.test.should == 'value'
    end

    it 'should be able to change value in storage' do
      @storage.storage = :value1
      @storage.storage = :value2
      @storage.storage.should == :value2
    end

    it 'should be able to store any data' do
      [
        ['string',  'value'   ],
        ['symbol',  :value    ],
        ['arrry',   [:a, :b]  ],
        ['hash',    {:a => :b}],
        ['integer', 1         ],
        ['float',   1.5       ],
        ['regexp',  /regexp/  ],
      ].each do |type, value|
        @storage.__send__("#{type}=", value)
        @storage.__send__(type).should == value
      end
    end

    it 'should raise error when add sub-storage to existed key' do
      @storage.sub = 'original value'
      lambda {
        @storage.sub.key = 'invalid substitution'
      }.should raise_error(
        NoMethodError,
        %r[undefined method `key=' for "original value":String]
      )
    end

    it 'should set intermediate defult configs' do
      @storage.set_default 'sub.more', 'value'
      @storage.sub.class.should == Storage
      @storage.sub.more.should == 'value'

      @storage.sub.set_default 'more', 'value'
    end
  end
end

