#-*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe Termtter::Client, 'when the plugin footer is loaded' do
  before do
    config.footer = "[termtter]"
    Termtter::Client.register_hook(
      :name => :test,
      :points => [:pre_exec_update],
      :exec_proc => lambda {|cmd, arg| decided_arg = arg}
    )
    Termtter::Client.register_command(:name => :update, :aliases => [:u], :exec => lambda{|_|})
  end

  before(:each) do
    decided_arg = nil
    decided_arg.should be_nil
  end

  it 'should add hook add_footer and command footer' do
    Termtter::Client.should_receive(:register_hook).once
    Termtter::Client.should_receive(:register_command).once
    Termtter::Client.plug 'footer'
  end

  it 'check footer' do
    Termtter::Client.call_commands('u foo')
    config.footer.should == '[termtter]'
    decided_arg.should == 'foo [termtter]'
  end

  it 'change footer' do
    Termtter::Client.call_commands('footer #termtter')
    config.footer.should == '#termtter'
    Termtter::Client.call_commands('u bar')
    decided_arg.should == 'bar #termtter'
  end

  it 'set no footer' do
    Termtter::Client.call_commands('footer')
    config.footer.should == nil
    Termtter::Client.call_commands('u hoge')
    decided_arg.should == 'hoge'
  end
end
