# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

describe Termtter::Client, 'when the plugin favorite is loaded' do
  it 'should add command favorite' do
    Termtter::Client.should_receive(:register_command).once
    plugin 'favorite'
  end
end
