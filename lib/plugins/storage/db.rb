# -*- coding: utf-8 -*-
 
require 'forwardable'

module Termtter::Client
  config.plugins.storage.set_default(:backend, :sqlite3)
end

module Termtter::Storage
  DATABASE_BACKEND = {
    :sqlite3 => "SQLite3",
    :sequel => "squerl",
    :groonga => "groonga"
  }
 
  class DB
    extend Forwardable

    def initialize
      backend = config.plugins.storage.backend
      load File.dirname(__FILE__) + "/#{DATABASE_BACKEND[backend].downcase}.rb"
      @db = (Termtter::Storage.const_get(DATABASE_BACKEND[backend])).new
    end

    def_delegators :@db, :setup, :name, :update, :find_text, :find_user
  end
end
