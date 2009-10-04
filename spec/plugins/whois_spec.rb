# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

describe Termtter::Client, 'when the plugin whois is loaded' do
  it 'adds the command whois' do
    Termtter::Client.should_receive(:register_command).once
    Termtter::Client.plug 'whois'
  end

  it 'should be whois define' do # What does "be whois define" mean?
    Termtter::Client.plug 'whois'
    name = 'jp-in-f104.google.com'
    ip = '66.249.89.104'

    whois?(name).should == ip
    whois?(ip).should == name
    # FIXME: This spec doesn't pass in Canada
  end
end
