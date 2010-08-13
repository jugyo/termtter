# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'
describe Termtter do
  it 'pause plugin' do
    Termtter::Client.should_receive(:pause)
    Termtter::Client.plug 'pause'
  end
end
