module Termtter
  module API
    class << self
      attr_reader :connection, :twitter
      def setup
        @connection = Connection.new
        @twitter = Termtter::Twitter.new(configatron.user_name, configatron.password, @connection)
      end
    end
  end
end
# Termtter::API.connection, Termtter::API.twitter can be accessed.
