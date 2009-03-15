# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'
describe Termtter do
  it 'pause plugin' do
    Termtter::Client.should_receive(:pause)
    plugin 'pause'
  end
end
