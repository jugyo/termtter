# -*- coding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__)) + '/spec_helper'

describe Termtter, 'when plugin is called (without init option)' do
  it 'should require global plugin if exist' do
    Termtter::Client.should_receive(:load).with('plugins/aaa.rb')
    Termtter::Client.plug 'aaa'
  end

  it 'should require user plugin if not exist' do
    Termtter::Client.should_receive(:load).with('plugins/aaa.rb')
    Termtter::Client.plug 'aaa'
  end

  it 'should handle_error if there are no plugins in global or user' do
    Termtter::Client.should_receive(:handle_error)
    Termtter::Client.plug 'not-exist-plugin-hehehehehehe'
  end
end

describe Termtter, 'when plugin is called (with init option)' do
  it 'init option will become config' do
    Termtter::Client.should_receive(:load)
    Termtter::Client.plug 'aaa', :bbb => :ccc
    config.plugins.aaa.bbb.should == :ccc
  end
end

describe Termtter, 'when termtter is loaded' do
  it 'will add load path' do
    termtter_path = File.expand_path(File.dirname(__FILE__) + '/../lib/termtter.rb')
    termtter_lib_path = File.dirname(termtter_path)
    original_load_path = $:.dup
    $:.delete(termtter_lib_path)
    $:.include?(termtter_lib_path).should == false
    be_quiet { load termtter_path }
    $:.include?(termtter_lib_path).should == true
    $:.concat(original_load_path)
  end
end
