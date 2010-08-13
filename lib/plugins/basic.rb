# -*- coding: utf-8 -*-
config.access_token = ''
config.access_token_secret = ''

module OAuth
  class AccessToken
    def initialize(consumer, access_token, access_token_secret)
    end
  end
end
module Termtter
  class RubytterProxy
    def initialize(access_token, twitter_option)
      user_name = config.plugins.basic.user_name
      password = config.plugins.basic.password
      @rubytter = Rubytter.new(user_name, password, twitter_option)
    end
  end
end

# basic.rb
# Use Basic Auth instead of OAuth
#
# config.plugins.basic.user_name = 'your_name'
# config.plugins.basic.password = 'the secret'
