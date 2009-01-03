Termtter::Client.add_hook do |statuses, event, t|
  t.public_storage[:uris] ||= []
  if !statuses.empty? && event == :update_friends_timeline
    statuses.each do |s|
      t.public_storage[:uris] += s.text.scan(%r|https?://[^\s]+|)
    end
  end
end

class Termtter::Client
  add_command /^uri-open\s*$/ do |m, t|
    t.public_storage[:uris] ||= [] # It's not DRY
    t.public_storage[:uris].each do |uri|
      # FIXME: works only in OSX and other *NIXs
      if /linux/ =~ RUBY_PLATFORM
        system 'firefox', uri
      else
        system 'open', uri
      end
    end
    t.public_storage[:uris].clear
  end
end
# ~/.termtter
# require 'termtter/uri-open'
#
# see also: http://ujihisa.nowa.jp/entry/c3dd00c4e0
#
# KNOWN BUG
# * In Debian, exit or C-c in the termtter kills your firefox.
