# -*- coding: utf-8 -*-
module Termtter::Client
  @last_screen_name = nil
  @last_source = nil
  @last_time = nil

  register_hook(
    :name => :reduce_screenname,
    :point => :prepare_screenname,
    :exec => lambda {|n, event|
      @last_screen_name == n ? '' : @last_screen_name = n
    }
  )

  register_hook(
    :name => :reduce_source,
    :point => :prepare_source,
    :exec => lambda {|n, event| @last_source == n ? '' : @last_source = n }
  )

  register_hook(
    :name => :reduce_time,
    :point => :prepare_time,
    :exec => lambda {|n, event| @last_time == n ? '' : @last_time = n }
  )
end
