require File.dirname(__FILE__) + '/../../lib/termtter'

describe Termtter::Client, 'when the plugin spam is loaded' do
  it 'should add command spam and post immediately' do
    t = Termtter::Twitter.new('a', 'b')
    Termtter::Twitter.should_receive(:new).and_return(t)
    t.should_receive(:update_status).with('*super spam time*')

    Termtter::Client.should_receive(:clear_commands)
    Termtter::Client.should_receive(:add_command).with(/.+/)
    plugin 'spam'
  end
end

