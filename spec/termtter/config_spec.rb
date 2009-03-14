# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

module Termtter

  describe Config do

    before do
      @storage = Config.new
    end

    it 'should be able to store value to new storage' do
      @storage.new_storage = :value
      @storage.new_storage.should == :value
    end

    it 'should be able to make subb.key and store value' do
      @storage.subb.key = :value
      @storage.subb.key.should == :value
    end

    it 'should be able to make multiple storage' do
      @storage.subb.more.for.test = 'value'
      @storage.subb.more.for.test.should == 'value'
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

    it 'should raise error when add subb-storage to existed key' do
      @storage.subb = 'original value'
      lambda {
        @storage.subb.key = 'invalid subbstitution'
      }.should raise_error(
        NoMethodError,
        %r[undefined method `key=' for "original value":String]
      )
    end

    it 'should set intermediate defult configs' do
      @storage.set_default 'subb.more', 'value'
      @storage.subb.class.should == Config
      @storage.subb.more.should == 'value'

      @storage.subb.set_default 'more', 'value'
    end

    it 'should ' do
      @storage.subb.more.set_default :moremore, 'value'
      @storage.subb.more.moremore.should == 'value'
    end
  end
end

