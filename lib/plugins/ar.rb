# -*- coding: utf-8 -*-
require 'active_record'
config.plugins.db.set_default(:path, Termtter::CONF_DIR + '/termtter.db')

ActiveRecord::Base.logger=Logger.new(nil)
ActiveRecord::Base.establish_connection(
  :adapter  => "sqlite3",
  :database => config.plugins.db.path
)

class Status < ActiveRecord::Base
  belongs_to :user
end
class User < ActiveRecord::Base
  has_many :statuses
end

unless Status.table_exists?()
  ActiveRecord::Migration.create_table :statuses do |t|
    t.column :user_id, :integer
    t.column :text, :string
    t.column :created_at, :string
    t.column :in_reply_to_status_id, :integer
    t.column :in_reply_to_user_id, :integer
    t.column :retweeted_status, :boolean
    t.column :source, :string
  end
end

unless User.table_exists?()
  ActiveRecord::Migration.create_table :users do |t|
    t.column :screen_name, :string
    t.column :protected, :boolean
    t.column :uid, :integer
  end
end

module Termtter
  module Client
    register_hook(:collect_statuses_for_db, :point => :pre_filter) do |statuses, event|
      statuses.each do |s|
        # Save users
        unless User.exists?(s.user.id)
          user = {}
          User.columns.map{|x| x.name.intern }.each do |col|
            user[col] =
              if event.class == SearchEvent && col == :protected
                false
              elsif col == :uid
                s.user.id
              elsif col != :id
                s.user[col]
              end
          end
          User.create(user)
        end

        # Save statuses
        unless Status.exists?(s.id)
          status = {}
          Status.columns.map{|x| x.name.intern }.each do |col|
            status[col] =
              col != :user_id ? (s[col] rescue nil) : nil
          end
          u = User.find(:first,
                        :conditions => ['uid = :i', {:i => s.user.id}])
          u.statuses.create(status)
        end
      end
    end

    register_command(:db_search, :alias => :ds) do |arg|
      statuses = Status.find(:all,
                             :conditions => ['text LIKE :l',
                                             {:l => "%" + arg + "%"}],
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
      statuses = Status.find(:all,
                             :joins      => "LEFT OUTER JOIN users ON users.uid = statuses.user_id",
                             :conditions => ['users.screen_name = :u',{:u => user_name}],
                             :limit      => 20)
      output(statuses, :db_search)
    end

    register_command(:db_execute) do |arg|
      ActionRecord::Base.connection.execute(arg).each do |row|
        p row
      end
    end
  end
end
