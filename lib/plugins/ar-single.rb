# -*- coding: utf-8 -*-
require 'active_record'
config.plugins.db.set_default(:path, Termtter::CONF_DIR + '/termtter.db')

ActiveRecord::Base.logger=Logger.new(nil)
ActiveRecord::Base.establish_connection(
  :adapter  => "sqlite3",
  :database => config.plugins.db.path
)

class Status < ActiveRecord::Base
end

unless Status.table_exists?()
  ActiveRecord::Migration.create_table :statuses do |t|
    t.column :uid, :integer
    t.column :screen_name, :string
    t.column :id_str, :string
    t.column :text, :string
    t.column :created_at, :datetime
    t.column :protected, :boolean
    t.column :in_reply_to_status_id, :integer
    t.column :in_reply_to_user_id, :integer
    t.column :in_reply_to_screen_name, :string
    t.column :statuses_count, :integer
    t.column :friends_count, :integer
    t.column :followers_count, :integer
    t.column :source, :string
  end
end

module Termtter
  module Client
    register_hook(:collect_statuses_for_db, :point => :pre_filter) do |statuses, event|
      statuses.each do |s|
        unless Status.exists?(s.id)
          status = {}
          Status.columns.map{|x| x.name.intern }.each do |col|
            status[col] =
              if col == :uid
                s.user.id
              elsif col == :screen_name || col == :statuses_count || col == :friends_count || col == :followers_count || col == :protected
                s.user[col]
              else
                s[col]
              end
          end
          Status.create(status)
        end
      end
    end

    register_command(:db_search, :alias => :ds) do |arg|
      statuses = Status.find(
        :all,
        :conditions => [
          'text LIKE :l',
          {:l => "%" + arg + "%"}],
        :limit => 20)
      output(statuses, :db_search)
    end

    register_command(:db_clear) do |arg|
      if confirm('Are you sure?')
        Status.delete_all
      end
    end

    register_command(:db_list) do |arg|
      user_name = normalize_as_user_name(arg)
      statuses = Status.find(
        :all,
        :conditions => ['statuses.screen_name = :u',{:u => user_name}],
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
