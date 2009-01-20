require File.dirname(__FILE__) + '/../spec_helper'

describe Termtter::Client, 'when the plugin shell is loaded' do
  it 'should add command shell' do
    Termtter::Client.should_receive(:add_help)
    Termtter::Client.should_receive(:add_macro).with(/^(?:shell|sh)\s*$/, "eval system ENV['SHELL'] || ENV['COMSPEC']")
    plugin 'shell'
  end
end
