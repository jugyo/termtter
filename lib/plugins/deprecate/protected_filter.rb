# -*- coding: utf-8 -*-

Termtter::Client.register_hook(
  :name => :protected_filter,
  :point => :filter_for_output,
  :exec => lambda { |statuses, event|
    statuses.select { |s| !s.user.protected }
  }
)
