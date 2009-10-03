# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

module Termtter
  describe API do
    before do
      API.module_eval{
        @twitter = nil
      }
    end

    it 'can create twitter' do
      t = API.create_twitter('foo', 'username')
      t.class.should == Rubytter
      t.login.should == 'foo'
    end

    it 'can create twitter' do
      API.setup
      API.twitter.class.should == Rubytter
    end

    it 'can restore user' do
      API.restore_user
      API.twitter.class.should == Rubytter
    end

    it 'can switch user' do
      API.switch_user('foo', 'password')
      API.twitter.login.should == 'foo'
      API.switch_user('bar', 'password')
      API.twitter.login.should == 'bar'
    end

  end
end

