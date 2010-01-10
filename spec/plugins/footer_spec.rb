#-*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Termtter::Client, 'when the plugin footer is loaded' do
  before do
    config.footer = "[termtter]"
    Termtter::Client.register_hook(
      :name => :test,
      :points => [:pre_exec_update],
      :exec_proc => lambda {|cmd, arg| @decided_arg = arg}
    )
    Termtter::Client.register_command(:name => :update, :aliases => [:u], :exec => lambda{|_|})
  end

  before(:each) do
    @decided_arg = nil
  end

  it 'should add hook add_footer and command footer' do
    Termtter::Client.should_receive(:register_hook).once
    Termtter::Client.should_receive(:register_command).once
    Termtter::Client.plug 'footer'
  end

  it 'should add footer at update' do
    @decided_arg.should be_nil
    Termtter::Client.call_commands('update foo')
    config.footer.should == '[termtter]'
    @decided_arg.should == 'foo [termtter]'
  end

  it 'should call footer command to change config.footer' do
    Termtter::Client.call_commands('footer #termtter')
    config.footer.should == '#termtter'
    @decided_arg.should be_nil
    Termtter::Client.call_commands('update bar')
    @decided_arg.should == 'bar #termtter'
  end

  it 'should call footer no argument to set config.footer to nil' do
    Termtter::Client.call_commands('footer')
    config.footer.should == nil
    @decided_arg.should be_nil
    Termtter::Client.call_commands('update hoge')
    @decided_arg.should == 'hoge'
  end
end

