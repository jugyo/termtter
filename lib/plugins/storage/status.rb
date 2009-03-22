# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/DB'
require 'sqlite3'

module Termtter::Storage
  class Status
    KEYS = %w[post_id created_at in_reply_to_status_id in_reply_to_user_id post_text user_id screen_name]

    def self.size
      DB.instance.db.get_first_value("select count(*) from post").to_i
    end

    def self.search(query)
      raise "query must be Hash(#{query}, #{query.class})" unless query.kind_of? Hash
      if query[:text] == nil then
        query[:text] = '';
      end
      if query[:user] == nil then
        query[:user] = '';
      end
      result = []
      sql = "select created_at, screen_name, post_text, in_reply_to_status_id, post_id, user_id "
      sql += "from post inner join user on post.user_id = user.id where post_text like '%' || ? || '%'"
      DB.instance.db.execute(sql,
                             query[:text]) do |created_at, screen_name, post_text, in_reply_to_status_id, post_id, user_id|
        created_at = Time.at(created_at).to_s
        result << {
          :id => post_id,
          :created_at => created_at,
          :text => post_text,
          :in_reply_to_status_id => in_reply_to_status_id,
          :in_reply_to_user_id => nil,
          :user => {
            :id => user_id,
            :screen_name => screen_name
          }
        }
      end
      Rubytter.json_to_struct(result)
    end

    def self.search_user(query)
      raise "query must be Hash(#{query}, #{query.class})" unless query.kind_of? Hash
      result = []
      sql = "select created_at, screen_name, post_text, in_reply_to_status_id, post_id, user_id "
      sql += "from post inner join user on post.user_id = user.id where "
      sql += query[:user].split(' ').map!{|que| que.gsub(/(\w+)/, 'screen_name like \'%\1%\'')}.join(' or ')
      DB.instance.db.execute(sql) do |created_at, screen_name, post_text, in_reply_to_status_id, post_id, user_id|
        created_at = Time.at(created_at).to_s
        result << {
          :id => post_id,
          :created_at => created_at,
          :text => post_text,
          :in_reply_to_status_id => in_reply_to_status_id,
          :in_reply_to_user_id => nil,
          :user => {
            :id => user_id,
            :screen_name => screen_name
          }
        }
      end
      Rubytter.json_to_struct(result)
    end

    def self.insert(data)
      DB.instance.db.execute(
                             "insert into post values(?,?,?,?,?,?)",
                             data[:post_id],
                             data[:created_at],
                             data[:in_reply_to_status_id],
                             data[:in_reply_to_user_id],
                             data[:text],
                             data[:user_id])
      DB.instance.db.execute(
                             "insert into user values(?,?)",
                             data[:user_id],
                             data[:screen_name])
    rescue SQLite3::SQLException
    end
  end
end
