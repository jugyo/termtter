require File.dirname(__FILE__) + '/../spec_helper'

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
      Client.call_commands('draft list')
    end

    it 'should clear drafts' do
      Client.call_commands('draft clear')
      Client.public_storage[:drafts].size.should == 0
    end

    it 'should exec last draft' do
      Client.should_receive(:call_commands).with('bar')
      Client.get_command(:'draft exec').call('draft exec')
    end

    it 'should exec specified draft' do
      Client.should_receive(:call_commands).with('foo')
      Client.get_command(:'draft exec').call('draft exec', '0')
    end

    it 'should not exec draft if index is wrong' do
      Client.should_not_receive(:call_commands)
      Client.get_command(:'draft exec').call('draft exec', '2')
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
      Client.get_command(:'draft delete').call('draft delete', '2')
      Client.public_storage[:drafts].should == ["foo", "bar"]
    end
  end
end
