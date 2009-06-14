# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

describe Termtter::Client, 'when the plugin primes is loaded' do
  it 'should add command primes' do
    Termtter::Client.should_receive(:register_command).once
    Termtter::Client.plug 'primes'
  end

  it 'should define primes method' do
    Termtter::Client.plug 'primes'
    (0..10).map {|i| primes i }.should == ["", "", "", "2, 3", "2, 3", "2, 3, 5", "2, 3, 5", "2, 3, 5, 7", "2, 3, 5, 7", "2, 3, 5, 7", "2, 3, 5, 7"]
  end
end
