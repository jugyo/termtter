# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/DB.rb'
require 'sqlite3'

module Termtter::Storage
  class Status
    KEYS = %w[post_id created_at in_reply_to_status_id in_reply_to_user_id post_text user_id screen_name]

    def size
      DB.instance.db.get_first_value("select count(*) from post").to_i
    end

    def search(query)
      raise "query must be Hash(#{query}, #{query.class})" unless query.kind_of? Hash
    end

    def self.insert(data)
      raise "data must be Hash(#{data}, #{data.class})" unless data.kind_of? Hash
      # 条件しぼりたいけどやりかたがうまくわからない
#      raise "unko" unless data.keys.all?{|c| KEYS.include? c}

      DB.instance.db.execute(
        "insert into post values(?,?,?,?,?,?)",
        data[:post_id],
        data[:created_at],
        data[:in_reply_to_status_id],
        data[:in_reply_to_user_id],
        data[:post_text],
        data[:user_id])
      begin
        DB.instance.db.execute(
                               "insert into user values(?,?)",
                               data[:user_id],
                               data[:screen_name])
      rescue
      end
    end
  end
end
