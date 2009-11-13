# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

describe Termtter::Client, 'when the plugin curry is loaded' do
  it 'should add command curry' do
    Termtter::Client.should_receive(:register_command).twice
    Termtter::Client.should_receive(:register_hook).twice
    Termtter::Client.plug 'curry'
  end
end

# FIXME: Lack of specs
