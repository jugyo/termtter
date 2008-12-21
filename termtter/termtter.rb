require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'cgi'
require 'readline'
require 'enumerator'

class Termtter
  
  @@handlers = []

  def self.add_hook(&handler)
    @@handlers << handler
  end

  def initialize(conf)
    @user_name = conf[:user_name]
    @password = conf[:password]
    @update_interval = conf[:update_interval] || 300
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

  # user_timeline と friends_timeline でメソッド分けたほうがいいかも  
  def fetch_friends_timeline(options)
    if options[:user_id]
      uri = "http://twitter.com/statuses/user_timeline/#{options[:user_id]}.xml"
    elsif options[:all]
      uri = "http://twitter.com/statuses/friends_timeline.xml"
      if options[:updated]
        if @since_id && !@since_id.empty?
          uri += "?since_id=#{@since_id}"
        end
      else
        @since_id = nil
      end
    end

    if uri
      statuses = get_timeline(uri)
      call_handlers(statuses)
    end
  rescue => e
    puts "Error: #{e}. request uri => #{uri}"
  end

  def call_handlers(statuses)
    @@handlers.each do |h|
      h.call(statuses)
    end
  end

  def get_timeline(uri)
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
    
    return statuses
  end

  def run
    Thread.new do
      while true
        fetch_friends_timeline(:all => true, :updated => true)
        sleep @update_interval
      end
    end

    stty_save = `stty -g`.chomp
    trap("INT") { system "stty", stty_save; exit }

    while buf = Readline.readline("", true)
      case buf
      when ''
        # do nothing
      when /^@([^\s]+)$/
        fetch_friends_timeline(:user_id => $1)
      when 'list'
        fetch_friends_timeline(:all => true)
      else
        update_status(buf)
        puts "post> #{buf}"
      end
    end
  end

end

