# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

describe 'db' do
  DB_PATH = '/tmp/termtter.db'

  before(:each) do
    File.delete(DB_PATH) if File.exists?(DB_PATH)
    config.plugins.db.path = DB_PATH
    load 'plugins/db.rb'
  end

  after do
    File.delete(DB_PATH) if File.exists?(DB_PATH)
  end

  it 'should created db file' do
    File.exists?(DB_PATH)
  end

  it 'saves statuses' do
    now = Time.now.to_s
    Status << {:user_id => 1, :text => 'foo', :created_at => now}
    dataset = Status.all
    dataset.size.should == 1
    dataset[0].user_id.should == 1
    dataset[0].text.should == 'foo'
    dataset[0].created_at.should == now
  end

  it 'saves users' do
    User << {:screen_name => 'jugyo'}
    dataset = User.all
    dataset.size.should == 1
    dataset[0].screen_name.should == 'jugyo'
  end

  it 'calls hook' do
    user_struct = Struct.new(:id, :screen_name)
    user_1 = user_struct.new(1, 'jugyo')
    user_2 = user_struct.new(2, 'oyguj')

    status_struct = Struct.new(:id, :text, :source, :user, :in_reply_to_status_id,
      :in_reply_to_user_id, :created_at)
    statuses = []
    statuses << status_struct.new(1, 'foo', 'termtter', user_1, 100, Time.now.to_s)
    statuses << status_struct.new(2, 'bar', 'termtter', user_1, nil, nil, Time.now.to_s)
    statuses << status_struct.new(3, 'xxx', 'web', user_2, nil, nil, Time.now.to_s)

    Termtter::Client.hooks[:collect_statuses_for_db].call(statuses, :update_friends_timeline)

    dataset = User.all
    dataset.size.should == 2

    dataset = Status.all
    dataset.size.should == 3

    User[:id => 1].statuses.size.should == 2
    Status[:id => 1].user.id.should == 1
  end
end
