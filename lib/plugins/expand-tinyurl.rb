# -*- coding: utf-8 -*-

module Termtter::Client
  add_filter do |statuses, event|
    statuses.each do |s|
      s.text.gsub!(%r'(http://tinyurl\.com(/[\w/]+))') do |m|
        expand_tinyurl($2) || $1
      end
    end
    statuses
  end
end

def expand_tinyurl(path)
  http_class = Net::HTTP
  unless config.proxy.host.nil? or config.proxy.host.empty?
    http_class = Net::HTTP::Proxy(config.proxy.host,
                                  config.proxy.port,
                                  config.proxy.user_name,
                                  config.proxy.password)
  end
  res = http_class.new('tinyurl.com').head(path)
  res['Location']
end
