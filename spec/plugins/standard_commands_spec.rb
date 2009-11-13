# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'
Termtter::Client.plug 'defaults/standard_commands'

module Termtter
  describe Client do
    it 'returns registerd commands' do
      [
        [:update,  [:u]],  [:direct,  [:d]],
        [:profile, [:p]],  [:list,    [:l]],
        [:search,  [:s]],  [:replies, [:r]],
        [:show,    [  ]],  [:shows,   [  ]],
        [:limit,   [:lm]], [:pause,   [  ]],
        [:resume,  [  ]],  [:exit,    [:quit]],
      ].each do |name, aliases|
        command = Client.get_command(name)
        command.name.should == name
        command.aliases.should == aliases
      end
    end
  end

  describe 'standard_commands' do
    it 'needs more specs!'
  end
end
