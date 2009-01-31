# -*- coding: utf-8 -*-

module Termtter
  class User
    %w[ name favourites_count url id description protected utc_offset time_zone
        screen_name notifications statuses_count followers_count friends_count
        profile_image_url location following created_at
    ].each do |attr|
      attr_accessor attr.to_sym
    end
  end  
end

