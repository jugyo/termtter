require File.dirname(__FILE__) + '/../../lib/termtter'

module Termtter
  describe Client, 'when the plugin plugin is loaded' do
    it 'should add command plugin and plugins' do
      Termtter::Client.should_receive(:register_command).twice
      plugin 'plugin'
    end

    it 'should set public_storage[:plugins]' do
      plugin 'plugin'
      Client::public_storage[:plugins].should_not be_empty
    end

    describe 'after the plugin plugin is loaded' do
      before { plugin 'plugin' }

      it 'should load the given plugin in the command plugin'
      # hmm... How can I write it...?
    end
  end
end

