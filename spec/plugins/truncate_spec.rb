# -*- coding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'

describe Termtter::Client, 'when the plugin truncate is loaded' do

  it 'should add command truncate' do
    Termtter::RubytterProxy.should_receive(:register_hook).once
    be_quiet { Termtter::Client.plug 'truncate' }
  end

  it 'should define truncate method' do
    be_quiet { Termtter::Client.plug 'truncate' }

    truncate('11111').should == '11111'

    truncate('1' * 140).should == '1' * 140

    truncate('1' * 141).should == '1' * 137 + '...'

    truncate('あああああ').should == 'あああああ'

    truncate('あ' * 140).should == 'あ' * 140

    truncate('あ' * 141).should == 'あ' * 137 + '...'
  end

  it 'should skip URLs at the end as possible' do
    be_quiet { Termtter::Client.plug 'truncate' }

    u1 = ' http://example.com/'

    truncate('あああああ' + u1).should == 'あああああ' + u1

    truncate('あ' * (140 - u1.size) + u1).should == 'あ' * (140 - u1.size) + u1
    truncate('あ' * (141 - u1.size) + u1).should ==
      'あ' * (140 - '...'.size - u1.size) + '...' + u1

    truncate('あ' * (140 - u1.size * 2) + u1 * 2).should ==
      'あ' * (140 - u1.size * 2) + u1 * 2
    truncate('あ' * (141 - u1.size * 2) + u1 * 2).should ==
      'あ' * (140 - '...'.size - u1.size * 2) + '...' + u1 * 2

    u2 = u1 + 'x' * (140 - 1 - u1.size)
    truncate('あ' + u2).should == 'あ' + u2
    truncate('あ' * 2 + u2).should ==
      'あ' * 2 + u1 + 'x' * (140 - u1.size - 2 - '...'.size) + '...'

    u3 = u1 + 'x' * (140 - 3 - u1.size)
    truncate('あ' * 3 + u3).should == 'あ' * 3 + u3
    truncate('あ' * 4 + u3).should ==
      'あ' * 4 + u1 + 'x' * (140 - u1.size - 4 - '...'.size) + '...'

    u4 = u1 + 'x' * (140 - 4 - u1.size)
    truncate('あ' * 4 + u4).should == 'あ' * 4 + u4
    truncate('あ' * 5 + u4).should == 'あ...' + u4

    u5 = u1 + 'x' * 150
    truncate('あ' * 5 + u5).should ==
      'あ' * 5 + u1 + 'x' * (140 - u1.size - 5 - '...'.size) + '...'
  end
end
