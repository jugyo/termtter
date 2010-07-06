# -*- coding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'

module Termtter
  describe Config do
    before do
      @config = Config.new
    end

    describe 'freeze' do
      before do
        @config.foo = 'foo'
        @config.__freeze__(:foo)
      end

      it 'can not change value' do
        @config.foo = 'bar'
        @config.foo.should == 'foo'
      end

      it 'can not clear value' do
        @config.__clear__(:foo)
        @config.foo.should == 'foo'
      end

      it 'can unfreeze' do
        @config.__unfreeze__(:foo)
        @config.foo = 'bar'
        @config.foo.should == 'bar'
      end
    end

    it 'can store value to new storage' do
      @config.new_storage = :value
      @config.new_storage.should == :value
    end

    it 'can make subb.key and store value' do
      @config.subb.key = :value
      @config.subb.key.should == :value
    end

    it 'can make multiple storage' do
      @config.subb.more.for.test = 'value'
      @config.subb.more.for.test.should == 'value'
    end

    it 'can change value in storage' do
      @config.storage = :value1
      @config.storage = :value2
      @config.storage.should == :value2
    end

    it 'can inspect' do
      @config.storage = :value
      @config.inspect.should == {:storage => :value}.inspect
    end

    it 'can get __values__' do
      @config.storage = :value
      @config.__values__.should == {:storage => :value}
    end

    it 'can __clear__' do
      @config.storage = :value
      @config.storage.should == :value
      @config.__clear__
      result = @config.__values__
      result.should be_empty
      result.should be_an_instance_of Hash
    end 

    it 'can be called __clear__ with name' do
      @config.foo = 'foo'
      @config.foo.should_not be_empty
      @config.__clear__(:foo)
      @config.foo.should be_empty
    end

    it 'can store any data' do
      [
        ['string',  'value'   ],
        ['symbol',  :value    ],
        ['arrry',   [:a, :b]  ],
        ['hashes',    {:a => :b}],
        ['integer', 1         ],
        ['float',   1.5       ],
        ['regexp',  /regexp/  ],
      ].each do |type, value|
        @config.__send__("#{type}=", value)
        @config.__send__(type).should == value
      end
    end

    it 'can raise error when add by prohibited name' do
      lambda {
        @config.set_default('open.aaa', :value)
        @config.open.aaa
      }.should raise_error
    end

    it 'can raise error when add subb-storage to existed key' do
      @config.subb = 'original value'
      lambda {
        @config.subb.key = 'invalid subbstitution'
      }.should raise_error(
        NoMethodError,
        %r[undefined method `key=' for "original value":String]
      )
    end

    it 'can set intermediate defult configs' do
      @config.set_default 'subb.more', 'value'
      @config.subb.class.should == Config
      @config.subb.more.should == 'value'

      @config.proxy.set_default(:port, 'value')
      @config.proxy.port.should == 'value'
    end

    # FIXME: Is this need spec?
#     it 'should have :undefined value in un-assigned key' do
#       @config.aaaa.should == :undefined
#     end

    it 'can examin that storage is empty' do
      @config.should be_empty
      @config.aaa = 1
      @config.should_not be_empty
      @config.bbb.should be_empty
    end

    it 'can examin that storage is not empty (nil)' do
      @config.bbb = nil
      @config.should_not be_empty
    end

    it 'can examin that storage is not empty (default)' do
      @config.set_default('aaa', 1)
      @config.should_not be_empty
    end

    it 'can use in expression' do
      @config.set_default(:ssb, 'hoge')
      lambda {
        res = @config.ssb + ' piyo'
        res.should == 'hoge piyo'
      }.should_not raise_error
    end

    it 'can not change value when call set_default twice' do
      @config.plugins.set_default :only, 'before_value'
      @config.plugins.set_default :only, 'after_value'
      @config.plugins.only.should == 'before_value'
    end

    it 'can be called set_default with int multiple times' do
      lambda {
        @config.set_default(:foo, 1)
        @config.set_default(:foo, 2)
        @config.foo.should == 1
      }.should_not raise_error
    end

    it 'can be called set_default with string multiple times' do
      lambda {
        @config.set_default(:foo, 'foo')
        @config.set_default(:foo, 'bar')
        @config.foo.should == 'foo'
      }.should_not raise_error
    end
  end
end
