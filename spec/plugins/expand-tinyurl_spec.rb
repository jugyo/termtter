# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

describe Termtter::Client, 'when the plugin expand-tinyurl is loaded' do

  it 'should define expand_url method' do
    be_quiet { Termtter::Client.plug 'expand-tinyurl' }

    expand_url('tinyurl.com', '/kotu').should == 'http://example.com/'

    expand_url('tinyurl.com', '/de5my6').should == 'http://example.com/テスト'

    expand_url('is.gd', '/5oDxw').should == 'http://example.com/'

    expand_url('to.ly', '/H0H').should == 'http://termtter.org/'

    expand_url('goo.gl', '/e').should == 'http://www.google.com/'
  end
end
