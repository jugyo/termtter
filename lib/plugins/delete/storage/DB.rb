# -*- coding: utf-8 -*-

require 'sqlite3'
require 'singleton'

module Termtter::Storage
  class DB
    include Singleton
    attr_reader :db

    def initialize
      @db = SQLite3::Database.new(Termtter::CONF_DIR + '/storage.db')
      @db.type_translation = true
      create_table
    end

    def create_table
      sql =<<-SQL
CREATE TABLE IF NOT EXISTS user (
    id          int NOT NULL,
    screen_name text,
    PRIMARY KEY (id)
);
CREATE TABLE IF NOT EXISTS post (
    post_id          int NOT NULL,  -- twitter側のpostのid
    created_at	     int,    	    -- 日付(RubyでUNIX時間に変換)
    in_reply_to_status_id int, 	    -- あったほうがよいらしい
    in_reply_to_user_id int,  	    -- あったほうがよいらしい
    post_text text,
    user_id int NOT NULL,
    PRIMARY KEY (post_id)
);
      SQL
      @db.execute_batch(sql)
    end
  end
end
