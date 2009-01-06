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
#   configatron.timeline_format = '<%= color(time, 90) %> <%= color(status, s.has_keyword ? 4 : status_color) %> <%= color(id, 90) %>'
#   configatron.plugins.keyword.keywords = [ /motemen/ ]
