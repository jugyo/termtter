# -*- coding: utf-8 -*-

module Termtter::Client

  register_hook(
    :name => :set_invoked_at,
    :point => :pre_filter,
    :exec_proc => lambda do |statuses, event|
      event[:invoked_at] = Time.now
      statuses
    end
  )

  register_hook(
    :name => :print_invoked_at,
    :point => :post_filter,
    :exec_proc => lambda do |statuses, event|
      puts "event was invoked at #{event.invoked_at}."
      statuses
    end
  )

end
