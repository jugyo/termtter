# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'



module Termtter

  describe User do

    before do

      @user = User.new

      @params = %w[ name favourites_count url id description protected utc_offset time_zone

          screen_name notifications statuses_count followers_count friends_count

          profile_image_url location following created_at

      ]

    end



    it 'should access to properties' do

      @params.each do |attr|

        @user.__send__(attr.to_sym).should == nil

      end



      @params.each do |attr|

        @user.__send__("#{attr}=".to_sym, 'foo')

        @user.__send__(attr.to_sym).should == 'foo'

      end

    end

  end

end


