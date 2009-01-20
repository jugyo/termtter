require File.dirname(__FILE__) + '/../spec_helper'

describe Termtter::Client, 'when the plugin cool is loaded' do
  it 'should add something about cool' do
    Termtter::Client.should_receive(:add_help)
    Termtter::Client.should_receive(:add_macro)
    Termtter::Client.should_receive(:add_completion)
    plugin 'cool'
  end
end
