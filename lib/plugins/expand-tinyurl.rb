# -*- coding: utf-8 -*-

URL_SHORTTERS = [
  { :host => "tinyurl.com", :pattern => %r'(http://tinyurl\.com(/[\w/]+))' },
  { :host => "is.gd", :pattern => %r'(http://is\.gd(/[\w/]+))' },
#  { :host => "bit.ly", :pattern => %r'(http://bit\.ly(/[\w/]+))' }
]

module Termtter::Client
  add_filter do |statuses, event|
    statuses.each do |s|
      URL_SHORTTERS.each do |site|
        s.text.gsub!(site[:pattern]) do |m|
          expand_url(site[:host], $2) || $1
        end
      end
    end
    statuses
  end
end

def expand_url(host, path)
  http_class = Net::HTTP
  unless config.proxy.host.nil? or config.proxy.host.empty?
    http_class = Net::HTTP::Proxy(config.proxy.host,
                                  config.proxy.port,
                                  config.proxy.user_name,
                                  config.proxy.password)
  end
  res = http_class.new('tinyurl.com').head(path)
  return nil unless res.code == "301" or res.code == "302"
  res['Location']
end
