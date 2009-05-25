# -*- coding: utf-8 -*-
require 'sequel'

module Termtter
  module DB
    config.plugins.db.set_default(:path, CONF_DIR + '/termtter.db')

    DB = Sequel.sqlite(config.plugins.db.path) if defined? DB

    unless DB.table_exists?(:statuses)
      DB.create_table :statuses do
        primary_key :id
        Integer :user_id
        String :text
        DateTime :created_at
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

    class Status < Sequel::Model
      many_to_one :user
    end
    
    class User < Sequel::Model
      one_to_many :statuses
    end
  end

  module Client
    register_hook(:collect_statuses_for_db, :point => :pre_filter) do |statuses, event|
      statuses.each do |s|
        if DB::Status.filter(:id => s.id).count == 0
          DB::Status << {
            :id => s.id,
            :text => s.text,
            :user_id => s.user.id,
            :created_at => Time.parse(s.created_at)
          }
        end

        if DB::User.filter(:id => s.user.id).count == 0
          DB::User << {
            :id => s.user.id,
            :screen_name => s.user.screen_name
          }
        end
      end
    end

    register_command(:db_search, :alias => :ds) do |arg|
      statuses = DB::Status.filter(:text.like("%#{arg}%"))
      output(statuses, :db_search)
    end
  end
end
