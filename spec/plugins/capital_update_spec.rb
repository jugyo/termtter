require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'

describe Termtter::Client, 'when the plugin capital_update is loaded' do
  it 'adds command capital_update' do
    Termtter::Client.should_receive(:register_command).once
    Termtter::Client.plug 'capital_update'
  end
end

