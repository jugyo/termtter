# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'



describe Termtter::Client, 'when the plugin shell is loaded' do

  it 'should add command shell' do

    Termtter::Client.should_receive(:register_command)

    plugin 'shell'

  end

end
