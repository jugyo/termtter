require 'base64'

module Termtter
  module Crypt
    def self.crypt(s)
      Base64.encode64(s)
    end

    def self.decrypt(s)
      Base64.decode64(s)
    end
  end
end
