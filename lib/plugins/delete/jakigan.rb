# -*- coding: utf-8 -*-

if RUBY_VERSION >= '1.9'
  # nop
elsif RUBY_VERSION >= '1.8.7'
  class Array
    alias sample choice
  end
else
  class Array
    def sample
      at(rand(size))
    end
  end
end

module Termtter::Client
  module Jakigan
    TEMPLATES = [
      # http://twitter.com/yugui/status/3086394151
      '%s、か。ククク、その真の意図、邪気眼を持たぬ者には分かるまい。',
      # http://twitter.com/Sixeight/statuses/3705973751
      '僕の邪気眼は%sです。'
    ]
  end
  register_macro(:jkg, "update #{Jakigan::TEMPLATES.sample}",
    :help => ['jkg {MESSAGE}', 'update "{MESSAGE}+something jkg."'],
    :alias => :jk
  )
end
