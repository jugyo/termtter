# -*- coding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'

describe Termtter::Client, 'when the plugin whois is loaded' do
  it 'should add command whois' do
    Termtter::Client.should_receive(:register_command).once
    Termtter::Client.plug 'whois'
  end

  it 'should be whois define' do
    Termtter::Client.plug 'whois'
    name = "jp-in-f104.google.com"
    ip = "66.249.89.104"
    
    whois?(name).should == ip
    whois?(ip).should == name 
  end
  
end
