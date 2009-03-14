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
        ['hashes',    {:a => :b}],
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

      @storage.proxy.set_default(:port, 'value')
      @storage.proxy.port.should == 'value'
    end

    # FIXME: not work
#     it 'should have :undefined value in un-assigned key' do
#       @storage.aaaa.should == :undefined
#     end

    it 'should be empty when something is assigned' do
      @storage.empty?.should be_true

      @storage.aaa = 1
      @storage.empty?.should be_false

      @storage.bbb.empty?.should be_true
    end

    it 'should be empty when assigned nil' do
      @storage.bbb = nil
      @storage.empty?.should be_false
    end

    it 'should be empty when set_defaulted' do
      @storage.set_default('aaa', 1)
      @storage.empty?.should be_false
    end

    it 'should use in expression' do
      @storage.set_default(:ssb, 'hoge')
      lambda {
        res = @storage.ssb + ' piyo'
        res.should == 'hoge piyo'
      }.should_not raise_error
    end
  end
end

