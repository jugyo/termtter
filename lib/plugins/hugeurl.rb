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
    statuses.each do |s|
      config.plugins.hugeurl.skip_users.include?(s.user.screen_name) and next
      s.text.gsub!(HUGEURL_TARGET_PATTERN) do |m|
        res = Termtter::HTTPpool.start('search.twitter.com') do |h|
          h.get('/hugeurl?url=' + m)
        end
        res.code == '200' && res.body !~ /^</ ? res.body : m
      end
    end
    statuses
  end
)

# hugeurl.rb:
# expands bit.ly, tiniurl, etc. by search.twitter.com API
