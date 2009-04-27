# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'
plugin 'standard_commands'

module Termtter
  describe Client do
    it 'shold return registerd commands' do
      [
        [:update,  [:u]],  [:direct,  [:d]],
        [:profile, [:p]],  [:list,    [:l]],
        [:search,  [:s]],  [:replies, [:r]],
        [:show,    [  ]],  [:shows,   [  ]],
        [:limit,   [:lm]], [:pause,   [  ]],
        [:resume,  [  ]],  [:exit,    [:e]],
      ].each do |name, aliases|
        command = Client.get_command(name)
        command.name.should == name
        command.aliases.should == aliases
      end
    end
  end
end
