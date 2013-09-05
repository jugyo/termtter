# -*- coding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'

module Termtter
  describe Client, 'when the plugin is loaded' do
    DB_PATH = '/tmp/termtter.db'

    def clear_db
      File.delete(DB_PATH) if File.exists?(DB_PATH)
    end

    before(:each) do
      clear_db
    end

    after do
      clear_db
    end

    it 'should add commands' do
      Termtter::Client.should_receive(:register_command).exactly(4)
      Termtter::Client.plug 'ar-single'
    end

    it 'self.save should not return false and saved record should be readable' do
      config.plugins.db.path = DB_PATH
      load 'plugins/ar-single.rb'
      Termtter::Client.plug 'ar-single'
      @status = Status.new
      @status.screen_name = 'hoge'
      @status.id_str = '55555'
      @status.text = 'ほげ'
      @status.protected = true
      @status.statuses_count = 500
      @status.friends_count = 1000
      @status.followers_count = 1500
      @status.source = 'Termtter tests'
      @status.save.should_not be_false

      status_find = Status.find(:first)
      status_find.screen_name.should == 'hoge'
      status_find.id_str.should == '55555'
      status_find.text.should == 'ほげ'
      status_find.protected.should be_true
      status_find.statuses_count.should == 500
      status_find.friends_count.should == 1000
      status_find.followers_count.should == 1500
      status_find.source.should == 'Termtter tests'
    end

  end
end
