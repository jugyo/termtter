# -*- coding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__)) + '/../../spec_helper'

describe Termtter::Client, 'plugin expand_tco_url' do
  before do
    be_quiet { Termtter::Client.plug 'defaults/expand_tco_url' }
  end

  it 'should expand urls' do
    text1 = 'あいうえお http://example.com/xyz'
    urls1 = [{:url => 'http://example.com/xyz', :expanded_url => 'http://example.net/abc'}]
    Termtter::Client.expand_tco_urls!(text1, urls1)
    text1.should == 'あいうえお http://example.net/abc'
  end

  it 'should not raise exception when url does not matched' do
    text = 'text without urls'
    urls = [{:url => 'http://example.com/xyz', :expanded_url => 'http://example.net/abc'}]
    lambda { Termtter::Client.expand_tco_urls!(text, urls) }.should_not raise_exception
  end
end
