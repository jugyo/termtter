require 'base64'

module Termtter
  class Crypt
    def self.crypt(s)
      str = Base64.encode64(Base64.encode64(s.chars.to_a.map(&:ord)
                                                   .inspect).chars
                                                   .map(&:ord)
                                                   .map{|x| x+2 }
                                                   .map(&:chr).join)
      str
    end

    def self.decrypt(s)
      eval(Base64.decode64(Base64.decode64(s).chars.map{|x| x.ord - 2 }.map(&:chr).join)).map(&:chr).join('')
    end
  end
end


