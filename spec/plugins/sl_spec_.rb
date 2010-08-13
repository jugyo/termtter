# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'
describe Termtter do
  it 'plugin sl' do
    Termtter::Client.should_receive(:register_command).exactly(4).times
    Termtter::Client.plug 'sl'
  end
end
