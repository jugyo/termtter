require 'tmpdir'
require File.expand_path(File.dirname(__FILE__)) + '/../../spec_helper'
require File.expand_path(File.dirname(__FILE__)) + '/../../../lib/plugins/storage/sqlite3'

module Termtter::Storage
  describe "sqlite3" do
    DB_FILE = File.join(Dir.tmpdir, 'test.db')
    before(:each) do
      File.delete(DB_FILE) if File.exists?(DB_FILE)
      @db = Termtter::Storage::SQLite3.new(DB_FILE)
    end

    after do
      File.delete(DB_FILE) if File.exists?(DB_FILE)
    end

    it 'update should not return false' do
      pending("Not yet implemented")
      h = {
        :post_id => 1,
        :created_at => 12345,
        :in_reply_to_status_id => -1,
        :in_reply_to_user_id => -1,
        :text => 'bomb',
        :user_id => 1
      }
      @db.update(h).should_not be_false
    end

    it 'find_id returns status' do
    end

    it 'find_text returns status' do
    end

    it 'find_user returns status' do
    end

    it 'size of statuses' do
    end
  end
end
