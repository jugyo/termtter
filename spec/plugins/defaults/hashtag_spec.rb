require File.expand_path(File.dirname(__FILE__)) + '/../../spec_helper'

describe 'plugin hashtag' do
  before do
    Termtter::Client.clear_hooks
    Termtter::Client.setup_task_manager
    Termtter::Client.plug 'defaults'
  end

  describe 'spec for "hashtag add"' do
    before do
      Termtter::Client.public_storage[:hashtags].clear
    end

    it 'should add hashtag "test"' do
      Termtter::Client.execute('hashtag add test')
      Termtter::Client.public_storage[:hashtags].should == Set.new(['#test'])
    end

    it 'should add hashtag "#test"' do
      Termtter::Client.execute('hashtag add #test')
      Termtter::Client.public_storage[:hashtags].should == Set.new(['#test'])
    end

    it 'should add hashtags "foo", "bar"' do
      Termtter::Client.execute('hashtag add foo bar')
      Termtter::Client.public_storage[:hashtags].should == Set.new(["#foo", "#bar"])
    end
  end

  describe 'spec for hook of hashtag' do
    before do
      Termtter::Client.execute('hashtag add foo bar')
    end

    it 'add hashtags as args of command' do
      @update_command = Termtter::Client.commands[:update]
      @update_command.exec_proc.should_receive(:call).with("test #foo #bar")
      Termtter::Client.execute('update test')
    end
  end
end
