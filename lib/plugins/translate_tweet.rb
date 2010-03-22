# Description: Update translated tweet to (other|same) account when you're update
# Author: Sora Harakami

require 'open-uri'
require 'json'
require 'cgi'

def translate_by_google(text,o={})
  opt = {:from => "",:to => "en"}.merge(o)
  j = JSON.parse(open(
    "http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=" \
   +"#{CGI.escape(text)}&langpair=#{CGI.escape("#{opt[:from]}|#{opt[:to]}")}").read)
  j["responseData"]["translatedText"] rescue nil
end

config.plugins.translate_tweet.set_default(:to,"en")
config.plugins.translate_tweet.set_default(:user_name,nil)
config.plugins.translate_tweet.set_default(:password,nil)
config.plugins.translate_tweet.set_default(:header,"")
config.plugins.translate_tweet.set_default(:footer,"")

Termtter::Client.register_hook(
  :name  => :translate_tweet,
  :point => :post_exec_update,
  :exec  => lambda do |cmd,t,result|
    tw = (config.plugins.translate_tweet.user_name.nil? || \
         config.plugins.translate_tweet.password.nil?) ?  \
           Termtter::API.twitter : \
           Rubytter.new(config.plugins.translate_tweet.user_name,  \
                        config.plugins.translate_tweet.password)
    tt = config.plugins.translate_tweet.header + \
         translate_by_google( \
           t,:to => config.plugins.translate_tweet.to) + \
         config.plugins.translate_tweet.footer
    tw.update(tt)
    puts "translated => #{tt}"
  end
)
