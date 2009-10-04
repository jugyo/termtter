# -*- coding: utf-8 -*-

HUGEURL_TARGET_PATTERN = %r{
    http://tinyurl\.com/[\w/]+
  | http://is\.gd/[\w/]+
  | http://bit\.ly/[\w/]+
  | http://ff\.im/[-\w/]+
  | http://tr\.im/[\w/]+
}x

config.plugins.hugeurl.set_default(:skip_users, [])

Termtter::Client::register_hook(
  :name => :hugeurl,
  :point => :filter_for_output,
  :exec_proc => lambda do |statuses, event|
    http_class = Net::HTTP
    unless config.proxy.host.nil? or config.proxy.host.empty?
      http_class = Net::HTTP::Proxy(config.proxy.host,
                                    config.proxy.port,
                                    config.proxy.user_name,
                                    config.proxy.password)
    end
    http_class.start('search.twitter.com') do |http|
      statuses.each do |s|
        config.plugins.hugeurl.skip_users.include?(s.user.screen_name) and next
        s.text.gsub!(HUGEURL_TARGET_PATTERN) do |m|
          res = http.get('/hugeurl?url=' + m)
          res.code == '200' && res.body !~ /^</ ? res.body : m
        end
      end
    end
    statuses
  end
)

# hugeurl.rb:
# expands bit.ly, tiniurl, etc. by search.twitter.com API
