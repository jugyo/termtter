module Termtter::Client
  add_filter do |statuses|
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
  unless configatron.proxy.host.empty?
    http_class = Net::HTTP::Proxy(configatron.proxy.host,
                                  configatron.proxy.port,
                                  configatron.proxy.user_name,
                                  configatron.proxy.password)
  end
  res = http_class.new('tinyurl.com').head(path)
  res['Location']
end
