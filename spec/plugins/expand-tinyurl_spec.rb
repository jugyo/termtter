# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

describe Termtter::Client, 'when the plugin expand-tinyurl is loaded' do
  before do
    be_quiet { Termtter::Client.plug 'expand-tinyurl' }
  end

  it 'should define expand_url method' do
    # TODO: 直接ネットにアクセスしに行かないようにしたい。 fakeweb?

    expand_url('tinyurl.com', '/kotu').should == 'http://example.com/'

    expand_url('tinyurl.com', '/de5my6').should == 'http://example.com/テスト'

    expand_url('is.gd', '/5oDxw').should == 'http://example.com/'

    expand_url('goo.gl', '/e').should == 'http://www.google.com/'
  end
end
