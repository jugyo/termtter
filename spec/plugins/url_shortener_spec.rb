#-*- coding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'
require 'open-uri'
require 'uri'
require 'net/http'

describe 'plugin url_shortener' do
  before do
    Termtter::Client.setup_task_manager
  end

  it 'adds hook :url_shortener' do
    Termtter::Client.should_receive(:register_hook).once
    Termtter::Client.plug 'url_shortener'
    #Termtter::Client.get_hook(:url_shortener).should be_a_kind_of(Hook)
    #Termtter::Client.get_hook(:url_shortener).name.should == :url_shortener
  end

  it 'truncates url' do
    Termtter::Client.register_command(
      :name => :update, :alias => :u,
      :exec => lambda do |url|
        url.should match(/(bit\.ly|tinyurl|is\.gd)/)
        open(url) do |f|
          f.base_uri.to_s.should match('www.google')
        end
      end
    )
    Termtter::Client.plug 'url_shortener'
    Termtter::Client.execute('update http://www.google.com/')
  end

  it 'truncates url with not escaped Non-ASCII characters' do
    Termtter::Client.register_command(
      :name => :update, :alias => :u,
      :exec => lambda do |url|
        url.should match(/(bit\.ly|tinyurl|is\.gd)/)
        uri = URI.parse(url)
        Net::HTTP.new(uri.host,uri.port) do |h|
            r = h.get(uri.path)
            r['Location'].should match('http://ja.wikipedia.org/wiki/%E6%B7%B1%E7%94%B0%E6%81%AD%E5%AD%90')
        end
      end
    )
    Termtter::Client.plug 'url_shortener'
    Termtter::Client.execute('update http://ja.wikipedia.org/wiki/深田恭子')
  end

  it 'truncates url with escaped Non-ASCII characters' do
    Termtter::Client.register_command(
      :name => :update, :alias => :u,
      :exec => lambda do |url|
        url.should match(/(bit\.ly|tinyurl|is\.gd)/)
        open(url) do |f|
          f.base_uri.to_s.should match('http://ja.wikipedia.org/wiki/%E3%82%B9%E3%83%88%E3%83%AA%E3%83%BC%E3%83%88%E3%82%B3%E3%83%B3%E3%83%94%E3%83%A5%E3%83%BC%E3%83%86%E3%82%A3%E3%83%B3%E3%82%B0')
        end
      end
    )
    Termtter::Client.plug 'url_shortener'
    Termtter::Client.execute('update http://ja.wikipedia.org/wiki/%E3%82%B9%E3%83%88%E3%83%AA%E3%83%BC%E3%83%88%E3%82%B3%E3%83%B3%E3%83%94%E3%83%A5%E3%83%BC%E3%83%86%E3%82%A3%E3%83%B3%E3%82%B0')
  end

  it 'truncates url with many parameters' do
    Termtter::Client.register_command(
      :name => :update, :alias => :u,
      :exec => lambda do |url|
        url.should match(/(bit\.ly|tinyurl|is\.gd)/)
        open(url) do |f|
          f.base_uri.to_s.should match('hl=ja&source=hp&q=ujihisa&lr=&aq=f&aqi=g4g-r6&aql=&oq=&gs_rfai=')
        end
      end
    )
    Termtter::Client.plug 'url_shortener'
    Termtter::Client.execute('update http://www.google.co.jp/search?hl=ja&source=hp&q=ujihisa&lr=&aq=f&aqi=g4g-r6&aql=&oq=&gs_rfai=')

  end
end
