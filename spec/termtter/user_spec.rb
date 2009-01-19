require File.dirname(__FILE__) + '/../../lib/termtter'

module Termtter
  describe User do
    before do
      @user = User.new
    end

    it 'should access to properties' do
      %w[ name favourites_count url id description protected utc_offset time_zone
          screen_name notifications statuses_count followers_count friends_count
          profile_image_url location following created_at
      ].each do |attr|
        @user.__send__(attr.to_sym).should == nil
      end

      %w[ name favourites_count url id description protected utc_offset time_zone
          screen_name notifications statuses_count followers_count friends_count
          profile_image_url location following created_at
      ].each do |attr|
        @user.__send__("#{attr}=".to_sym, 'foo')
        @user.__send__(attr.to_sym).should == 'foo'
      end
    end
  end
end

