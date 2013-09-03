# -*- coding: utf-8 -*-

require 'fluent-logger'

config.plugins.fluentd.set_default(:host, 'localhost')
config.plugins.fluentd.set_default(:port, 8888)
config.plugins.fluentd.set_default(:tag,  'twitter.statuses')

module Termtter
  module Client
    @fluentd = Fluent::Logger::FluentLogger.open(nil,
       host = config.plugins.fluentd.host,
       port = config.plugins.fluentd.port
    )

    register_hook(:collect_statuses_for_db, :point => :pre_filter) do |statuses, event|
      statuses.each do |status|
        @fluentd.post(config.plugins.fluentd.tag, status)
      end
    end
  end
end
