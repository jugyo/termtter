# -*- coding: utf-8 -*-

module Termtter
  module API
    class << self
      attr_reader :connection, :twitter
      def setup
        @connection = Connection.new
        @twitter = Termtter::Twitter.new(config.user_name, config.password, @connection)
      end
    end
  end
end
# Termtter::API.connection, Termtter::API.twitter can be accessed.
