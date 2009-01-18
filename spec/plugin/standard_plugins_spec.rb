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

    it 'should return candidates when call find_status_id_candidates' do
      Client.public_storage[:status_ids] = %w[1 2 22 3 4 5]
      Client.find_status_id_candidates("1", "%s").should == ["1"]
      Client.find_status_id_candidates("2", "%s").should == ["2", "22"]
    end
  end
end

