# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'



describe Termtter::Client, 'when the plugin cool is loaded' do

  it 'should add something about cool' do

    Termtter::Client.should_receive(:register_macro)

    plugin 'cool'

  end

end
