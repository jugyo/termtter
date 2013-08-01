# -*- coding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'

describe Termtter::Client, 'when the plugin expand_url is loaded' do
  it 'should expand url in status' do
    f = nil
    Termtter::Client.should_receive(:register_hook).once do |params|
      f = params[:exec_proc]
    end
    config.plugins.expand_tinyurl.set_default('tinyurl.com', nil)
    Termtter::Client.plug 'expand_url'
    f.should_not be_nil
    status_struct = Struct.new(:text)
    statuses = []
    user_struct = Struct.new(:id, :screen_name, :protected)
    user_1 = user_struct.new(1, 'jugyo')
    user_2 = user_struct.new(2, 'oyguj')
    status_struct = Struct.new(:id, :text, :source, :user, :in_reply_to_status_id,
      :in_reply_to_user_id, :created_at)
    statuses << status_struct.new(1, '無変換 http://id774.net zzz', 'termtter', user_1, 100, nil, Time.now.to_s)
    statuses << status_struct.new(2, 'あああ http://goo.gl/U7dM4Z aaa', 'termtter', user_1, 100, nil, Time.now.to_s)
    statuses << status_struct.new(3, 'いいい http://is.gd/ZIqgo7 bbb', 'termtter', user_1, 100, nil, Time.now.to_s)
    statuses << status_struct.new(4, 'ううう http://bit.ly/1RvMdT ccc', 'termtter', user_1, 100, nil, Time.now.to_s)
    statuses << status_struct.new(5, 'えええ http://j.mp/1RvMdT ddd', 'termtter', user_1, 100, nil, Time.now.to_s)
    statuses << status_struct.new(6, 'おおお http://ow.ly/nwfAS eee', 'termtter', user_1, 100, nil, Time.now.to_s)
    statuses << status_struct.new(7, 'かかか http://twurl.nl/rxnjnt fff', 'termtter', user_1, 100, nil, Time.now.to_s)
    statuses << status_struct.new(8, 'ききき http://ow.ly/nwg5a ggg', 'termtter', user_1, 100, nil, Time.now.to_s)
    statuses << status_struct.new(9, 'くくく http://p.tl/mwda hhh', 'termtter', user_1, 100, nil, Time.now.to_s)

    # statuses << status_struct.new(2, 'bar', 'termtter', user_1, nil, nil, Time.now.to_s)
    # statuses << status_struct.new(3, 'xxx', 'web', user_2, nil, nil, Time.now.to_s)
    f.call(statuses, nil)
    statuses[0].text.should == '無変換 http://id774.net zzz'
    statuses[1].text.should == 'あああ http://id774.net/ aaa'
    statuses[2].text.should == 'いいい http://id774.net bbb'
    statuses[3].text.should == 'ううう http://id774.net/ ccc'
    statuses[4].text.should == 'えええ http://id774.net/ ddd'
    statuses[5].text.should == 'おおお http://id774.net eee'
    statuses[6].text.should == 'かかか http://id774.net fff'
    statuses[7].text.should == 'ききき http://id774.net ggg'
    statuses[8].text.should == 'くくく http://id774.net hhh'

  end

  it 'should define expand_url method' do
    expand_url('is.gd', '/5oDxw').should == 'http://example.com/'
    expand_url('goo.gl', '/e').should == 'http://www.google.com/'
  end
end
