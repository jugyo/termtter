require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'

module Termtter
  describe 'plugin draft' do
    before do
      Client.setup_task_manager
      Client.plug 'draft'
      Client.public_storage[:drafts].clear
      Client.public_storage[:drafts] << 'foo'
      Client.public_storage[:drafts] << 'bar'
      Client.stub!(:puts)
    end

    it 'should puts drafts' do
      Client.should_receive(:puts).with("0: foo")
      Client.should_receive(:puts).with("1: bar")
      Client.execute('draft list')
    end

    it 'should clear drafts' do
      Client.execute('draft clear')
      Client.public_storage[:drafts].size.should == 0
    end

    it 'should exec last draft' do
      Client.should_receive(:execute).with('bar')
      Client.get_command(:'draft exec').call('draft exec')
    end

    it 'should exec specified draft' do
      Client.should_receive(:execute).with('foo')
      Client.get_command(:'draft exec').call('draft exec', '0')
    end

    it 'should not exec draft if index is wrong' do
      pending("Not yet implemented")
      Client.should_not_receive(:execute)
      Client.get_command(:'draft exec').call('draft exec', '2')
      Client.should_not_receive(:execute)
      Client.get_command(:'draft exec').call('draft exec', 'a')
    end

    it 'should delete draft' do
      Client.get_command(:'draft delete').call('draft delete')
      Client.public_storage[:drafts].should == ["foo"]
    end

    it 'should delete specified draft' do
      Client.get_command(:'draft delete').call('draft delete', '0')
      Client.public_storage[:drafts].should == ["bar"]
    end

    it 'should not delete draft if index is wrong' do
      pending("Not yet implemented")
      Client.get_command(:'draft delete').call('draft delete', '2')
      Client.public_storage[:drafts].should == ["foo", "bar"]
      Client.get_command(:'draft delete').call('draft delete', 'a')
      Client.public_storage[:drafts].should == ["foo", "bar"]
    end
  end
end
