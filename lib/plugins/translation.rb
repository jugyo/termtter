# -*- coding: utf-8 -*-

require 'nokogiri'
require 'net/http'
require 'kconv'
require 'uri'

def translate(text, langpair)
  text = Termtter::API.twitter.show(text)[:text] if /^\d+$/ =~ text

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

Termtter::Client.register_command(
  :name => :en2ja,
  :exec_proc => lambda{|arg|
    puts "translating..."
    puts "=> #{translate(arg, 'en|ja')}"
  }
)

Termtter::Client.register_command(
  :name => :ja2en,
  :exec_proc => lambda{|arg|
    puts "translating..."
    puts "=> #{translate(arg, 'ja|en')}"
  }
)

# This plugin does not work yet.
# requirements
#   nokogiri (sudo gem install nokogiri)
