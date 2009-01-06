require File.dirname(__FILE__) + '/../../lib/termtter'

describe Termtter::Client, 'when the plugin plugin is loaded' do
  it 'should add command plugin' do
    Termtter::Client.should_receive(:add_command).with(/^plugin\s+(.*)/)
    plugin 'plugin'
  end
end

describe Termtter::Client, 'after the plugin plugin is loaded' do
  it 'should load the given plugin in the command plugin'
  # hmm... How can I write it...?
end
