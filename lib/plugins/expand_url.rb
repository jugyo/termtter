# -*- coding: utf-8 -*-

URL_SHORTTERS = [
  {:host => "tinyurl.com", :pattern => %r'(http://tinyurl\.com(/[\w/]+))'},
  {:host => "is.gd", :pattern => %r'(http://is\.gd(/[\w/]+))'},
  {:host => "bit.ly", :pattern => %r'(http://bit\.ly(/[\w/]+))'},
  {:host => "ff.im", :pattern => %r'(http://ff\.im(/[-\w/]+))'},
  {:host => "j.mp", :pattern => %r'(http://j\.mp(/[\w/]+))'},
  {:host => "goo.gl", :pattern => %r'(http://goo\.gl(/[\w/]+))'},
  {:host => "tr.im", :pattern => %r'(http://tr\.im(/[\w/]+))'},
  {:host => "short.to", :pattern => %r'(http://short\.to(/[\w/]+))'},
  {:host => "ow.ly", :pattern => %r'(http://ow\.ly(/[\w/]+))'},
  {:host => "u.nu", :pattern => %r'(http://u\.nu(/[\w/]+))'},
  {:host => "twurl.nl", :pattern => %r'(http://twurl\.nl(/\w+))'},
  {:host => "icio.us", :pattern => %r'(http://icio\.us(/\w+))'},
  {:host => "htn.to", :pattern => %r'(http://htn\.to(/\w+))'},
  {:host => "cot.ag", :pattern => %r'(http://cot\.ag(/\w+))'},
  {:host => "ht.ly", :pattern => %r'(http://ht\.ly(/\w+))'},
  {:host => "p.tl", :pattern => %r'(http://p\.tl(/\w+))'},
  {:host => "url4.eu", :pattern => %r'(http://url4\.eu(/\w+))'},
  {:host => "t.co", :pattern => %r'(http://t\.co(/\w+))'},
]

config.plugins.expand_tinyurl.set_default(:shortters, [])
config.plugins.expand_tinyurl.set_default(:skip_users, [])

Termtter::Client::register_hook(
  :name => :expand_url,
  :point => :filter_for_output,
  :exec_proc => lambda do |statuses, event|
    shortters = URL_SHORTTERS + config.plugins.expand_tinyurl.shortters
    skip_users = config.plugins.expand_tinyurl.skip_users
    statuses.each do |s|
      skip_users.include?(s.user.screen_name) and next
      shortters.each do |site|
        s.text.gsub!(site[:pattern]) do |m|
          expand_url(site[:host], $2) || $1
        end
      end
    end
    statuses
  end
)

def expand_url(host, path)
  res = Termtter::HTTPpool.start(host) do |h|
    h.get(path, { 'User-Agent' => 'Mozilla' })
  end
  return nil unless res.code =~ /\A30/
  newurl = res['Location']
  newurl.respond_to?(:force_encoding) ? newurl.force_encoding(Encoding::UTF_8) : newurl
rescue Exception => e
  Termtter::Client.handle_error(e)
  nil
end
