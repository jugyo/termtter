# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'
require 'highline'

describe Termtter do

  it 'provides create_highline' do
    h = create_highline
    h.class.should == HighLine
  end

  it 'provides win?' do
    be_quiet do
      original_ruby_platform = ::RUBY_PLATFORM
      ::RUBY_PLATFORM = 'darwin'
      win?.should == false
      ::RUBY_PLATFORM = 'mswin'
      win?.should == true
      ::RUBY_PLATFORM = original_ruby_platform
    end
  end

  it 'Readline can refresh line' do
    Readline::LIBREADLINE.should_receive(:rl_refresh_line).with(0, 0)
    Readline.refresh_line
  end

  it 'extend DL::Impoter when not be able to find DL::Importable' do
    be_quiet { DL::Importer = mock(:importer) }
    DL.stub(:const_defined?).with(:Importable).and_return(false)
    Readline::LIBREADLINE.should_receive(:extend).with(DL::Importer)
    load 'termtter/system_extensions.rb'
  end

  it 'can handle error when difine LIBREADLINE' do
    Readline::LIBREADLINE.stub(:extend) { raise }
    load 'termtter/system_extensions.rb'
    Readline::LIBREADLINE.should_not_receive(:rl_refresh_line)
    Readline.refresh_line
  end

  it 'can open browser that suites platform' do
    be_quiet(:stdout => false) do
      url = 'example.com'
      [
        ['linux',   'firefox'],
        ['mswin',   'explorer'],
        ['mingw',   'explorer'],
        ['bccwin',  'explorer'],
        ['darwin',  'open'],
        ['hogehog', 'open'],
      ].each do |platform, browser|
        ::RUBY_PLATFORM = platform
        self.should_receive(:system).with(browser, url)
        open_browser(url)
      end
    end
  end
end

