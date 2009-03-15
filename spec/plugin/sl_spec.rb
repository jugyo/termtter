# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'
describe Termtter do
  it 'plugin sl' do
    Termtter::Client.should_receive(:register_command).exactly(4).times
    plugin 'sl'
  end
end
