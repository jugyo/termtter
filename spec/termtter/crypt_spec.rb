# coding: utf-8

require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'
require 'termtter/crypt'

module Termtter
  describe Crypt do
    it '.crypt crypts string' do
      Crypt.crypt('hi').should be_kind_of(String)
    end
    it '.decrypt decrypts string' do
      a = Crypt.crypt('hi')
      Crypt.decrypt(a).should == 'hi'
    end
  end
end
