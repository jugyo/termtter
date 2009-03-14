# -*- coding: utf-8 -*-

require 'sqlite3'

module Termtter::Storage

  class Status

    def initialize
    end

    def self.create
    end

    def self.all
      []
    end

    def self.search
    end

    private

    def db 
      @db || @db = connect
    end

    def connect
      @db = SQLite3::Database.new(File.expand_path('~/test.db'))
      @db.type_translation = true
    end

  end
end
