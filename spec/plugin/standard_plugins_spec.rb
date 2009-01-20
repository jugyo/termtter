$:.unshift(File.dirname(__FILE__) + '/../../lib')
require 'termtter'
require 'plugin/standard_plugins' # load plugins

module Termtter
  describe Client do
    it 'shold return registerd commands' do
      [
        [:update,  [:u]],
        [:direct,  [:d]],
        [:profile, [:p]],
        [:list,    [:l]],
        [:search,  [:s]],
        [:replies, [:r]],
        [:show,    []],
        [:shows,   []],
        [:limit,   [:lm]],
        [:pause,   []],
        [:resume,  []],
        [:exit,    [:e]],
      ].each do |name, aliases|
        command = Client.get_command(name)
        command.name.should == name
        command.aliases.should == aliases
      end
    end

    it 'should return candidates when call find_status_id_candidates' do
      Client.public_storage[:status_ids] = %w[1 2 22 3 4 5]
      Client.find_status_id_candidates("1", "%s").should == ["1"]
      Client.find_status_id_candidates("2", "%s").should == ["2", "22"]
      #TODO: more spec for like "jugyo:1113830"
    end
  end
end

