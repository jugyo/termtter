configatron.set_default('plugins.keyword.keywords', [])

module Termtter
  class Status
    def has_keyword?
      configatron.plugins.keyword.keywords.find { |k| k === self.text }
    end
    alias :has_keyword :has_keyword?
  end
end

# keyword.rb
#   provides a keyword watching method
# example config
#   configatron.timeline_format = '<%= s.has_keyword ? "\e[4m#{status}\e[0m" : status %>'
#   configatron.plugins.keyword.keywords = [ /motemen/ ]
