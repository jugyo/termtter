$:.unshift(File.dirname(__FILE__) + '/../../lib')
require 'termtter'
require 'plugin/standard_plugins' # load plugins

module Termtter
  describe Client do
    it 'shold return registerd commands' do
      command = Client.get_command(:profile)
      command.name.should == :profile
      # TODO: more spec for commands
    end
  end
end

