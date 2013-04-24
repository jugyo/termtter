# -*- coding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'

describe Termtter::Client, 'when the plugin expand-tinyurl is loaded' do
  it 'should expand url in status' do
    f = nil
    Termtter::Client.should_receive(:register_hook).once do |params|
      f = params[:exec_proc]
    end
    config.plugins.expand_tinyurl.set_default('tinyurl.com', nil)
    Termtter::Client.plug 'expand-tinyurl'
    f.should_not be_nil
    status_struct = Struct.new(:text)
    statuses = []
    user_struct = Struct.new(:id, :screen_name, :protected)
    user_1 = user_struct.new(1, 'jugyo')
    user_2 = user_struct.new(2, 'oyguj')
    status_struct = Struct.new(:id, :text, :source, :user, :in_reply_to_status_id,
      :in_reply_to_user_id, :created_at)
    statuses << status_struct.new(1, 'あああ http://tinyurl.com/de5my6 aaa', 'termtter', user_1, 100, nil, Time.now.to_s)
    statuses << status_struct.new(2, 'bar', 'termtter', user_1, nil, nil, Time.now.to_s)
    statuses << status_struct.new(3, 'xxx', 'web', user_2, nil, nil, Time.now.to_s)
    f.call(statuses, nil)
    statuses[0].text.should == 'あああ http://example.com/テスト aaa'
  end

  it 'should define expand_url method' do
    expand_url('is.gd', '/5oDxw').should == 'http://example.com/'
    expand_url('goo.gl', '/e').should == 'http://www.google.com/'
  end
end
