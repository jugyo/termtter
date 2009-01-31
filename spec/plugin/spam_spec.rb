# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

describe Termtter::Client, 'when the plugin spam is loaded' do
  it 'should add command spam and post immediately' do
    connection = mock('connection', :null_object => true)
    t = Termtter::Twitter.new('a', 'b', connection)
    Termtter::Twitter.should_receive(:new).and_return(t)
    t.should_receive(:update_status).with('*super spam time*')

    Termtter::Client.should_receive(:clear_commands)
    Termtter::Client.should_receive(:add_command).with(/.+/)
    plugin 'spam'
  end
end

