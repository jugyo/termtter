# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/spec_helper'

module Termtter
  describe Twitter, 'when get_timeline called' do
    before do
      connection = mock('connection', :null_object => true)
      @twitter = Termtter::Twitter.new('test', 'test', connection)

      Termtter::Client.add_hook do |statuses, event|
        @statuses = statuses
        @event = event
      end
    end

    it 'should get timeline' do
      @twitter.should_receive(:open).
        and_return(
          File.open(
            File.dirname(__FILE__) + "/../test/friends_timeline.json"))
      statuses = @twitter.get_timeline('')
      statuses.size.should == 3
      statuses[0].user_id.should == 102
      statuses[0].user_screen_name.should == 'test2'
      statuses[0].user_name.should == 'Test User 2'
      statuses[0].text.should == 'texttext 2'
      statuses[0].user_url.should == 'http://twitter.com/test2'
      statuses[0].user_profile_image_url.should ==
        'http://s3.amazonaws.com/twitter_production/profile_images/000/102.png'
      statuses[0].created_at.to_s.should == 'Sat Jan 03 21:13:45 +0900 2009'

      statuses[2].user_id.should == 100
      statuses[2].user_screen_name.should == 'test0'
      statuses[2].user_name.should == 'Test User 0'
      statuses[2].text.should == 'texttext 0'
      statuses[2].user_url.should == 'http://twitter.com/test0'
      statuses[2].user_profile_image_url.should ==
        'http://s3.amazonaws.com/twitter_production/profile_images/000/100.png'
      statuses[2].created_at.to_s.should == 'Sat Jan 03 21:13:45 +0900 2009'
    end
  end
end
