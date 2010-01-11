# -*- coding: utf-8 -*-
require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter  => "sqlite3",
  :dbfile => config.plugins.db.path
)

class Status << ActiveRecord::Base
  belong_to :user
end
class User << ActiveRecord::Base
  has_many :statuses
end

unless Status.table_exists?()
  ActiveRecord::Migration.create_table :statuses do |t|
    t.column :user_id, :integer
    t.column :text, :string
    t.column :created_at, :string
    t.column :in_reply_to_status_id, :integer
    t.column :in_reply_to_user_id, :integer
  end
end

unless User.table_exists?()
  ActiveRecord::Migration.create_table :users do |t|
    t.column :screen_name, :string
    t.column :protected, :boolean
  end
end

module Termtter
  module Client
    register_hook(:collect_statuses_for_db, :point => :pre_filter) do |statuses, event|
      statuses.each do |s|

        # Save statuses
        if Status.exists?(s.id)
          status = {}
          Status.columns.map{|x| x.name.intern }.each do |col|
            status[col] =
              case col
              when :user_id
                s.user.id
              else
                s[col] rescue nil
              end
          end
          Status.create status
        end

        # Save users
        if User.exists?(s.user.id)
          user = {}
          User.columns.map{|x| x.name.intern }.each do |col|
            user[col] =
              if event.class == SearchEvent && col == :protected
                false
              else
                s.user[col]
              end
          end
          User.create user
        end

      end
    end

    register_command(:db_search, :alias => :ds) do |arg|
      statuses = Status.find(:conditions => ['text LIKE :l', {:l => "%#{arg}%"}],
                             :limit      => 20)
      output(statuses, :db_search)
    end

    register_command(:db_clear) do |arg|
      if confirm('Are you sure?')
        User.delete_all
        Status.delete_all
      end
    end

    register_command(:db_list) do |arg|
      user_name = normalize_as_user_name(arg)
      statuses = Status.find(:joins => "LEFT OUTER JOIN users ON users.user_id = users.id",
                             :conditions => )
     #statuses = Status.join(:users, :id => :user_id).filter(:users__screen_name => user_name).limit(20)
      output(statuses, :db_search)
    end

    register_command(:db_execute) do |arg|
      DB.execute(arg).each do |row|
        p row
      end
    end
  end
end
