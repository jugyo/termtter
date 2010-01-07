# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../../../lib/plugins/storage/db'

module Termtter::Storage
  describe "db" do
    before(:each) do
    end

    it "create sqlite3 instance" do
      config.plugins.storage.backend = :sqlite3
      @db = DB.new
      @db.name.should == "sqlite3"
    end
  end
end
