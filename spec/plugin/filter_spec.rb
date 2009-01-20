require File.dirname(__FILE__) + '/../spec_helper'

module Termtter
  describe Client, 'when the filter plugin is loaded' do
    it 'should add command filter, filters and unfilter' do
      Termtter::Client.should_receive(:add_command).with(/^filter\s+(.*)/)
      Termtter::Client.should_receive(:add_command).with(/^filters\s*$/)
      Termtter::Client.should_receive(:add_command).with(/^unfilter\s*$/)
      plugin 'filter'
    end

    it 'should set public_storage[:filters]' do
      plugin 'filter'
      Client::public_storage.keys.should be_include(:filters)
    end
  end
end

