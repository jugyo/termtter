#!/usr/bin/env ruby

$KCODE = 'u'

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'cgi'
require 'readline'
require 'optparse'
require 'enumerator'

class TwitterClient

  @since_id = nil

  def initialize(user_name, password)
    @user_name = user_name
    @password = password
  end

  def update_status(status)
    req = Net::HTTP::Post.new('/statuses/update.xml')
    req.basic_auth(@user_name, @password)
    req.add_field("User-Agent", "Termtter http://github.com/jugyo/termtter")
    req.add_field("X-Twitter-Client", "Termtter")
    req.add_field("X-Twitter-Client-URL", "http://github.com/jugyo/termtter")
    req.add_field("X-Twitter-Client-Version", "0.1")
    Net::HTTP.start("twitter.com", 80) do |http|
      http.request(req, "status=#{CGI.escape(status)}")
    end
  end

  def fetch_timeline
    uri = 'http://twitter.com/statuses/friends_timeline.xml'
    if @since_id && !@since_id.empty?
      uri += "?since_id=#{@since_id}"
    end

    begin
      statuses = []
      doc = Nokogiri::XML(open(uri, :http_basic_authentication => [@user_name, @password]))

      new_since_id = doc.xpath('//status[1]/id').text
      @since_id = new_since_id if new_since_id && !new_since_id.empty?

      doc.xpath('//status').each do |s|
        status = {}
        %w(
          id text created_at truncated in_reply_to_status_id in_reply_to_user_id 
          user/id user/name user/screen_name
        ).each do |key|
          status[key] = CGI.unescapeHTML(s.xpath(key).text)
        end
        statuses << status
      end
      
      output(statuses)
    rescue => e
      puts "Error: #{e}. request uri => #{uri}"
    end
  end

  def color(str, num)
    "\e[#{num}m#{str}\e[0m"
  end

  def user_color(user_name)
    colors = %w(0 31 32 33 34 35 36 91 92 93 94 95 96)
    colors[user_name.hash % colors.size]
  end

  def output(statuses)
    return if statuses.empty?
    
    puts color(Time.now.strftime('%X'), 100)
    statuses.reverse.each do |s|
      text = s['text'].gsub("\n", '').split(//u).enum_for(:each_slice, 32).map{|i|i.join}.join("\n" + " " * 16)
      user_color = user_color(s['user/screen_name'])
      status = "#{s['user/screen_name'].rjust(15)} #{text}"
      puts color(status, user_color)
    end
  end

end

user_name = nil
password = nil
update_interval = 60

ARGV.options {|o|
  o.on('-u user_name') {|v| user_name = v }
  o.on('-p password') {|v| password = v }
  o.parse!
  
  unless user_name && password
    puts o.help
    exit 1
  end
}

client = TwitterClient.new(user_name, password)

Thread.new do
  while true
    client.fetch_timeline
    sleep update_interval
  end
end

stty_save = `stty -g`.chomp
trap("INT") { system "stty", stty_save; exit }

while buf = Readline.readline("", true)
  unless buf.empty?
    client.update_status(buf)
  end
end
