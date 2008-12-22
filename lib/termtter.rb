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
  def get_friends_timeline(type)
    uri = "http://twitter.com/statuses/friends_timeline.xml"

    if type == :update_friends_timeline
      if @since_id && !@since_id.empty?
        uri += "?since_id=#{@since_id}"
      end
    end

    statuses = get_timeline(uri)
    call_handlers(statuses, type)
  rescue => e
    puts "Error: #{e}. request uri => #{uri}\n#{e.backtrace.join("\n")}"
  end

  def get_user_timeline(screen_name)
    uri = "http://twitter.com/statuses/user_timeline/#{screen_name}.xml"
    statuses = get_timeline(uri)
    call_handlers(statuses, :list_user_timeline)
  rescue => e
    puts "Error: #{e}. request uri => #{uri}\n#{e.backtrace.join("\n")}"
  end

  def search(query)
    uri = 'http://search.twitter.com/search.atom?q=' + CGI.escape(query)
    doc = Nokogiri::XML(open(uri))

    statuses = []
    ns = {'atom' => 'http://www.w3.org/2005/Atom'}
    doc.xpath('//atom:entry', ns).each do |node|
      status = {}
      status['created_at'] = node.xpath('atom:published', ns).text
      status['text'] = node.xpath('atom:content', ns).text.gsub(/<\/?[^>]*>/, '')
      name = node.xpath('atom:author/atom:name', ns).text
      status['user/screen_name'] = name.scan(/^(.*) \(/).flatten[0]
      status['user/name'] = name.scan(/\(.*\)/).flatten[0]
      statuses << status
    end

    call_handlers(statuses, :search)
  rescue => e
    puts "Error: #{e}. request uri => #{uri}\n#{e.backtrace.join("\n")}"
  end

  def call_handlers(statuses, event)
    @@handlers.each do |h|
      h.call(statuses, event)
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
        get_friends_timeline(:update_friends_timeline)
        sleep @update_interval
      end
    end

    stty_save = `stty -g`.chomp
    trap("INT") { system "stty", stty_save; exit }

    while buf = Readline.readline("", true)
      case buf
      when ''
        # do nothing
      when /^post\s*(.*)/
        unless $1.empty?
          update_status($1)
          puts "=> #{$1}"
        end
      when 'list'
        get_friends_timeline(:list_friends_timeline)
      when /^list\s+([^\s]+)/
        get_user_timeline($1)
      when /^search\s*(.*)/
        unless $1.empty?
          search($1)
        end
      when 'help'
        puts <<-EOS
help                print this help message
list                List the posts in your friends timeline
list [user_name]    List the posts in the the given user's timeline
post [text]         Post a new message
        EOS
      else
        puts <<-EOS
Unknown command "#{buf}"
Enter "help" for instructions
        EOS
      end
    end
  end

end

