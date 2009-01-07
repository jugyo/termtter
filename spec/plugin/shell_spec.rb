require File.dirname(__FILE__) + '/../../lib/termtter'

describe Termtter::Client, 'when the plugin shell is loaded' do
  it 'should add command shell' do
    Termtter::Client.should_receive(:add_command).with(/^shell/)
    plugin 'shell'
  end
end
