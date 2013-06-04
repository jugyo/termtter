# -*- coding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'

describe 'db' do
  DB_PATH = '/tmp/termtter.db'

  before(:each) do
    File.delete(DB_PATH) if File.exists?(DB_PATH)
    config.plugins.db.path = DB_PATH
    load 'plugins/db.rb'
  end

  after do
    File.delete(DB_PATH) if File.exists?(DB_PATH)
  end

end
