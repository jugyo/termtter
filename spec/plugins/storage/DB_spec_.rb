# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../../../lib/plugins/storage/DB'

module Termtter::Storage
  describe DB do
    before do
      @db = DB.instance.db
    end
  end
end
