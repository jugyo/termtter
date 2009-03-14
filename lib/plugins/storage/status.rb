# -*- coding: utf-8 -*-

require 'sqlite3'

module Termtter::Storage

  class Status

    def initialize
      @db = SQLite3::Database.new(File.expand_path('~/test.db'))
      @db.type_translation = true
    end

    def all
      []
    end

    def db 
      @db || create_table
    end

    def create_table

    end

  end
end
