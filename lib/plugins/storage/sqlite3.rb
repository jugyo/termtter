# -*- coding: utf-8 -*-

require 'sqlite3'
require 'lib/termtter/active_rubytter'

module Termtter::Storage
  class SQLite3

    def initialize(file = Termtter::CONF_DIR + '/storage.db')
      @db = ::SQLite3::Database.new(file)
      @db.type_translation = true
      create_table
    end

    def name
      "sqlite3"
    end

    CREATE_TABLE = <<-SQL
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
    def create_table
      @db.execute_batch(CREATE_TABLE)
    end

    def update(status)
      return nil if find_id(status[:post_id])
      insert(status)
    end

    def insert(status)
      return nil unless status[:text]
      @db.execute(
        "insert into post values(?,?,?,?,?,?)",
        status[:post_id],
        status[:created_at],
        status[:in_reply_to_status_id],
        status[:in_reply_to_user_id],
        status[:text],
        status[:user_id])
      @db.execute(
        "insert into user values(?,?)",
        status[:user_id],
        status[:screen_name])
    end

    FIND_ID = <<-EOS
select created_at, screen_name, post_text, in_reply_to_status_id, post_id, user_id
 from post inner join user on post.user_id = user.id where post_id = ?
EOS
    def find_id(id)
      result = nil
      @db.execute(FIND, id) do |created_at, screen_name, post_text, in_reply_to_status_id, post_id, user_id|
        result = Termtter::ActiveRubytter.new({
            :id => post_id,
            :created_at => created_at,
            :text => post_text,
            :in_reply_to_status_id => in_reply_to_status_id,
            :in_reply_to_user_id => nil,
            :user => {
              :id => user_id,
              :screen_name => screen_name
            }
          })
      end
      result
    end

    FIND = <<-EOS
select created_at, screen_name, post_text, in_reply_to_status_id, post_id, user_id
 from post inner join user on post.user_id = user.id where post_text like '%' || ? || '%'
EOS
    def find_text(text = '')
      result = []
      @db.execute(FIND, text) do |created_at, screen_name, post_text, in_reply_to_status_id, post_id, user_id|
        created_at = Time.at(created_at).to_s
        result << Termtter::ActiveRubytter.new({
            :id => post_id,
            :created_at => created_at,
            :text => post_text,
            :in_reply_to_status_id => in_reply_to_status_id,
            :in_reply_to_user_id => nil,
            :user => {
              :id => user_id,
              :screen_name => screen_name
            }
          })
      end
      result
    end

    FIND_USER = <<-EOS
select created_at, screen_name, post_text, in_reply_to_status_id, post_id, user_id 
from post inner join user on post.user_id = user.id where 
EOS
    def find_user(user = "")
      result = []
      sql = FIND_USER + user.split(' ').map!{|que| que.gsub(/(\w+)/, 'screen_name like \'%\1%\'')}.join(' or ')
      @db.execute(sql) do |created_at, screen_name, post_text, in_reply_to_status_id, post_id, user_id|
        created_at = Time.at(created_at).to_s
        result << Termtter::ActiveRubytter.new({
            :id => post_id,
            :created_at => created_at,
            :text => post_text,
            :in_reply_to_status_id => in_reply_to_status_id,
            :in_reply_to_user_id => nil,
            :user => {
              :id => user_id,
              :screen_name => screen_name
            }
          })
      end
      result
    end

    def size
      @db.get_first_value("select count(*) from post").to_i
    end
  end
end
