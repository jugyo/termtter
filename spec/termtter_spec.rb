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
  end
end
