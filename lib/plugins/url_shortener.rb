# -*- coding: utf-8 -*-

config.plugins.url_shortener.set_default(:shorturl_makers, [
    { :host => "api.bit.ly",
      :format => '/v3/shorten?login=termtter&apiKey=R_e7f22d523a803dbff7f67de18c109856&longUrl=%s&format=txt' },
    { :host => "is.gd", :format => '/api.php?longurl=%s' },
    { :host => "tinyurl.com", :format => '/api-create.php?url=%s' },
  ])
config.plugins.url_shortener.set_default(:ignore_regexp, %r{
    \Ahttp://bit\.ly/ | \Ahttp://tinyurl\.com/ | \Ahttp://is\.gd/
  | \Ahttp://ff\.im/ | \Ahttp://j\.mp/ | \Ahttp://goo\.gl/
  | \Ahttp://tr\.im/ | \Ahttp://short\.to/ | \Ahttp://ow\.ly/
  | \Ahttp://u\.nu/ | \Ahttp://twurl\.nl/  | \Ahttp://icio\.us/
  | \Ahttp://htn\.to/ | \Ahttp://cot\.ag/ | \Ahttp://ht\.ly/ | \Ahttp://p\.tl/
  | \Ahttp://url4\.eu/ | \Ahttp://t\.co/
}x )
config.plugins.url_shortener.set_default(:url_shortener_hook_commands, [:update, :reply, :retweet])
config.plugins.url_shortener.set_default(
  :uri_regexp,
  /#{URI.regexp(%w(http https ftp))}\S*/ )

# Shorten URLs in tweets which size is longer than this value.
# If you want to shorten only when over termtter's limit, set `140'
config.plugins.url_shortener.set_default(:when_over, 0)

module Termtter::Client
  register_hook(
    :name => :url_shortener,
    :points => config.plugins.url_shortener.url_shortener_hook_commands.map {|cmd|
      "modify_arg_for_#{cmd.to_s}".to_sym
    },
    :exec_proc => lambda {|cmd, arg|
      if config.plugins.url_shortener.when_over == 0 || # skip character count
          arg.charsize > config.plugins.url_shortener.when_over
        arg.gsub(config.plugins.url_shortener.uri_regexp) do |url|
          result = nil
          config.plugins.url_shortener.shorturl_makers.each do |site|
            result = shorten_url(url, site[:host], site[:format])
            break if result
          end
          result or url
        end
      else
        arg
      end
    }
  )

  # returns nil if not shorten
  def self.shorten_url(url, host, format)
    return url if config.plugins.url_shortener.ignore_regexp =~ url # already shorten
    url_enc = URI.escape(url, /[^a-zA-Z0-9.:]/)
    res = Termtter::HTTPpool.start(host) do |h|
      h.get(format % url_enc)
    end
    if res.code == '200'
      result = res.body
      if /"(http.*?)"/ =~ result
        result = $1
      elsif /"statusCode": "ERROR"/ =~ result
        return nil
      end
      result
    else
      nil
    end
  end
end

# url_shortener.rb
# make URLs in your update to convert tinyurl.com/XXXXXXX.
