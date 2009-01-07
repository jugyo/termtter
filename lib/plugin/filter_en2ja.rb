require 'nokogiri'
require 'net/http'
require 'kconv'

plugin 'english'

def en2ja(text)
  Net::HTTP.version_1_2 # Proxy に対応してない
  Net::HTTP.start('translate.google.com', 80) {|http|
    response = http.post('/translate_t', "langpair=en|ja&text=#{text}")
    doc = Nokogiri::HTML.parse(response.body)
    return doc.css('#result_box').text
  }
end

# TODO: add_filter

# This plugin does not work yet.
# requirements
#   nokogiri (sudo gem install nokogiri)
