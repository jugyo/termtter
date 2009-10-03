# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'
require 'termtter/config_setup'

module Termtter
  describe ConfigSetup do
    it "" do
      highline = mock('mock', :ask => 'username_or_password')
      ConfigSetup.stub(:create_highline).and_return(highline)
      File.stub(:exists?).and_return(true)
      io = StringIO.new
      File.stub(:open).and_yield(io)
      ConfigSetup.run
      io.rewind
      io.read.should match(/username_or_password/)
    end
  end
end
