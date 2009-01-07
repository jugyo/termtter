require 'nokogiri'
require 'net/http'
require 'kconv'

#plugin 'english'

module Termtter
  class Status
    def english?
      @text !~ /[一-龠]+|[ぁ-ん]+|[ァ-ヴー]+|[ａ-ｚＡ-Ｚ０-９]+/
    end
  end
end

def en2ja(text)
  Net::HTTP.version_1_2 # Proxy に対応してない
  Net::HTTP.start('translate.google.com', 80) {|http|
    response = http.post('/translate_t', "langpair=en|ja&text=#{text}")
    doc = Nokogiri::HTML.parse(response.body)
    return doc.css('#result_box').text
  }
end

# filter-en2ja.rb として切り出す
Termtter::Client.add_filter do |statuses|
  statuses.each do |s|
    if s.english?
      s.text = en2ja(s.text)
    end
  end
end

Termtter::Client.add_command /^en2ja\s+(.*)$/ do |m, t|
  puts "translating..."
  puts "=> #{en2ja(m[1])}"
end

# This plugin does not work yet.
# requirements
#   nokogiri (sudo gem install nokogiri)
