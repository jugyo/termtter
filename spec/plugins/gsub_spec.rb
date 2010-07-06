# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'
describe Termtter::Client, 'when the plugin gsub is loaded' do
  it 'plugin gsub' do
    f = nil
    Termtter::Client.should_receive(:register_hook).once do |params|
      f = params[:exec]
    end
    config.plugins.gsub.table = [[/^foo/, 'FOO'], ['bar']]
    Termtter::Client.plug 'gsub'
    f.should_not be_nil
    status_struct = Struct.new(:text)
    statuses = []
    statuses << status_struct.new('foobarbaz')
    f.call(statuses, nil)
    statuses[0].text.should == 'FOObaz'
  end
end
