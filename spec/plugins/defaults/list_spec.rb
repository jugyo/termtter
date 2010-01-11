require File.dirname(__FILE__) + '/../../spec_helper'

describe 'plugin lists' do
  before do
    Termtter::Client.setup_task_manager
    config.user_name = 'jugyo'
    @twitter_stub = Object.new
    Termtter::API.stub!(:twitter).and_return(@twitter_stub)
  end

  describe 'command list' do
    before do
      Termtter::Client.plug 'defaults'
      @command = Termtter::Client.commands[:list]
    end

    it 'command name is :lists' do
      @command.name.should == :list
    end

    it 'should call with no user_name' do
      response = []
      @twitter_stub.should_receive(:home_timeline).and_return(response)
      Termtter::Client.execute('list')
    end

    it 'should call with user_name' do
      response = []
      @twitter_stub.should_receive(:user_timeline).with('termtter', {}).and_return(response)
      Termtter::Client.execute('list termtter')
    end
  end
end
