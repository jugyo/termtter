# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../../../lib/plugins/storage/status'

module Termtter::Storage
  describe Status do
    before do
      @status = Status.new
    end
  end

  describe Status do

    it 'self.insert should not return false' do
      Status.insert({ :post_id => 1,
                       :created_at => 12345,
                       :in_reply_to_status_id => -1,
                       :in_reply_to_user_id => -1,
                       :post_text => 'bomb',
                       :user_id => 1
                     }).should_not == false
    end

  end
end
