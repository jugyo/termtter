# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

describe Termtter::Client, 'when the plugin cool is loaded' do
  before do
    $stdout, @old_stdout = StringIO.new, $stdout # FIXME That suspends any debug informations!
    @update_arg, @update_params = [], []
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

  after do
    config.system.cmd_mode = false
    Termtter::Client.exit
    $stdout = @old_stdout
  end

  it 'register command cool' do
    command = Termtter::Client.get_command(:cool)
    Termtter::Client.call_commands('cool')
    $stdout.rewind
    $stdout.read.should == "updated => cool.\n"
    @update_arg.should == ['cool.']
    @update_params.should == [{ }]
  end
end
