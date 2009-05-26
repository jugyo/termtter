# -*- coding: utf-8 -*-
require 'sequel'

config.plugins.db.set_default(:path, Termtter::CONF_DIR + '/termtter.db')

DB = Sequel.sqlite(config.plugins.db.path) unless defined? DB

unless DB.table_exists?(:statuses)
  DB.create_table :statuses do
    primary_key :id
    Integer :user_id
    String :text
    String :source
    String :created_at
    Integer :in_reply_to_status_id
    Integer :in_reply_to_user_id
  end
end

unless DB.table_exists?(:users)
  DB.create_table :users do
    primary_key :id
    String :screen_name
  end
end

class Status < Sequel::Model(:statuses)
  many_to_one :user
end

class User < Sequel::Model(:users)
  one_to_many :statuses
end

module Termtter
  module Client
    register_hook(:collect_statuses_for_db, :point => :pre_filter) do |statuses, event|
      statuses.each do |s|
        if Status.filter(:id => s.id).empty?
          Status << {
            :id => s.id,
            :text => s.text,
            :source => s.source,
            :user_id => s.user.id,
            :created_at => s.created_at
          }
        end

        if User.filter(:id => s.user.id).empty?
          User << {
            :id => s.user.id,
            :screen_name => s.user.screen_name
          }
        end
      end
    end

    register_command(:db_search, :alias => :ds) do |arg|
      statuses = Status.filter(:text.like("%#{arg}%")).limit(20)
      output(statuses, :db_search)
    end

    register_command(:db_clear) do |arg|
      if confirm('Are you shure?')
        User.delete
        Status.delete
      end
    end
  end
end
