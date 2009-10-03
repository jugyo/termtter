# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'
require 'highline'

describe Termtter do
  it 'provides create_highline' do
    h = create_highline
    h.class.should == HighLine
  end

  it 'provides win?' do
    original_ruby_platform = RUBY_PLATFORM
    RUBY_PLATFORM = 'darwin'
    win?.should == false
    RUBY_PLATFORM = 'mswin'
    win?.should == true
    RUBY_PLATFORM = original_ruby_platform
  end

end

