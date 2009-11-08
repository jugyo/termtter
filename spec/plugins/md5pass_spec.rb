# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'
describe Termtter::Client, 'when the plugin md5pass is loaded' do
  it 'plugin md5pass' do
    config.user_name = 'foo'
    Termtter::Client.should_receive(:register_command).once
    Termtter::Client.should_receive(:create_highline).and_return(
      mock(Termtter::Client, :ask => 'bar')
    )
    Termtter::Client.plug 'md5pass'
    config.password.should == "BuCE5l6YBVd2"
  end
end
