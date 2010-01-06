# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../../spec_helper'

describe 'Termtter::Client.post_retweet' do
  it 'posts a retweet based on the given post by someone, confirming if it is protected' do
    pending
  end
end

describe 'Plugin `retweet`' do
  it 'registers a commond when it is loaded' do
    Termtter::Client.should_receive(:register_command).at_least(5).times
    Termtter::Client.plug 'defaults/retweet'
  end
#
#  it 'should define fib method' do
#    Termtter::Client.plug 'defaults/fib'
#    (0..10).map {|i| fib i }.should == [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55]
#  end
end
