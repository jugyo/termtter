require File.dirname(__FILE__) + '/../../lib/termtter'

module Termtter
  describe Client, 'when the plugin repl is loaded' do
    it 'should add command "("' do
      Termtter::Client.should_receive(:add_command).with(/^\(.*/)
      plugin 'repl'
    end
  end
end
__END__

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

