# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../../../lib/plugins/storage/status'

module Termtter::Storage
  describe Status do
    before do
      @status = Status.new
    end
  end
  
  describe Status, "when empty" do
    before do
      @status = Status.new
    end
    it "should all return empty array" do
      @status.all.should == []
    end
  end

  describe Status, "when empty" do
    before do
      @status = Status.new
    end
    it "should all return empty array" do
      @status.all.should == []
    end
  end

  

end
