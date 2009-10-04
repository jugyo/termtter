# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

describe Termtter::Client, 'when the plugin cool is loaded' do
  before do
    @debug, @update_arg, @update_params = [], [], []
    Termtter::Client.plug 'multi_output'
    Termtter::Client.delete_output(:stdout)
    Termtter::Client.register_output(:debug) do |msg|
      @debug << msg
    end
    config.system.cmd_mode = true
    Termtter::Client.run
    Termtter::API.twitter.stub!(:update) {|arg, param|
      @update_arg.push(arg)
      @update_params.push(param)
      a = mock('Foo')
      a.should_receive(:text).and_return(arg)
      a
    }
    Termtter::Client.plug 'cool'
  end

  it 'register command cool' do
    command = Termtter::Client.get_command(:cool)
    Termtter::Client.call_commands('cool')
    @debug.should == ['updated => cool.']
    @update_arg.should == ['cool.']
    @update_params.should == [{ }]
  end
end
