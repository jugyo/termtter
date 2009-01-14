module Termtter
  module API
    def self.setup
      @@connection = Connection.new
      @@twitter = Termtter::Twitter.new(configatron.user_name, configatron.password)
    end
    def self.twitter
      @@twitter
    end
    def self.connection
      @@connection
    end
  end
end

