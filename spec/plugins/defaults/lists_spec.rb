require File.dirname(__FILE__) + '/../../spec_helper'

describe 'plugin lists' do
  before do
    config.user_name = 'jugyo'
    @twitter_stub = Object.new
    Termtter::API.stub!(:twitter).and_return(@twitter_stub)
  end

  describe 'command lists' do
    before do
      Termtter::Client.plug 'defaults'
      @command = Termtter::Client.commands[:lists]
    end

    it 'command name is :lists' do
      @command.name.should == :lists
    end

    it 'should call with no user_name' do
      response = Object.new
      response.stub!(:lists).and_return({})
      @twitter_stub.should_receive(:lists).with('jugyo').and_return(response)
      Termtter::Client.call_commands('lists')
    end

    it 'should call with user_name' do
      response = Object.new
      response.stub!(:lists).and_return({})
      @twitter_stub.should_receive(:lists).with('termtter').and_return(response)
      Termtter::Client.call_commands('lists termtter')
    end
  end
end
