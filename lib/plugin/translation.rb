require 'nokogiri'
require 'net/http'
require 'kconv'
require 'uri'

def transelate(text, langpair)
  req = Net::HTTP::Post.new('/translate_t')
  req.add_field('Content-Type', 'application/x-www-form-urlencoded')
  req.add_field('User-Agent', 'Mozilla/5.0')
  Net::HTTP.version_1_2 # Proxy に対応してない
  Net::HTTP.start('translate.google.co.jp', 80) {|http|
    response = http.request(req, "langpair=#{langpair}&text=#{URI.escape(text)}")
    doc = Nokogiri::HTML.parse(response.body, nil, 'utf-8')
    return doc.css('#result_box').text
  }
end

Termtter::Client.add_command /^(en2ja|ja2en)\s+(.*)$/ do |m, t|
  langpair = m[1].gsub('2', '|')
  puts "translating..."
  puts "=> #{transelate(m[2], langpair)}"
end

# This plugin does not work yet.
# requirements
#   nokogiri (sudo gem install nokogiri)
