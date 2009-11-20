# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

describe Termtter::Client, 'when the plugin truncate is loaded' do

  it 'should add command truncate' do
    Termtter::Client.should_receive(:register_hook).once
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
end
