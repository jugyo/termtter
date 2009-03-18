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
      result = []
      DB.instance.db.execute("select created_at, screen_name, post_text, in_reply_to_status_id, post_id from post inner join user on post.user_id = user.id where post_text like '%' || ? || '%' ",
                             query[:post_text]) do |created_at, screen_name, post_text, in_reply_to_status_id, post_id|
        created_at = Time.at(created_at).to_s
        result << {
          :id => post_id,
          :created_at => created_at,
          :screen_name => screen_name,
          :post_text => post_text,
          :in_reply_to_status_id => in_reply_to_status_id,
        }
      end
      result
    end

    def self.insert(data)
      DB.instance.db.execute(
                             "insert into post values(?,?,?,?,?,?)",
                             data[:post_id],
                             data[:created_at],
                             data[:in_reply_to_status_id],
                             data[:in_reply_to_user_id],
                             data[:post_text],
                             data[:user_id])
      DB.instance.db.execute(
                             "insert into user values(?,?)",
                             data[:user_id],
                             data[:screen_name])
    rescue SQLite3::SQLException
    end
  end
end
