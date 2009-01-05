module Termtter::Client
  public_storage[:uris] = []

  add_hook do |statuses, event, t|
    if !statuses.empty? && event == :update_friends_timeline
      statuses.each do |s|
        public_storage[:uris] += s.text.scan(%r|https?://[^\s]+|)
      end
    end
  end

  add_command /^uri-open\s*$/ do |m, t|
    public_storage[:uris].each do |uri|
      # FIXME: works only in OSX and other *NIXs
      if /linux/ =~ RUBY_PLATFORM
        system 'firefox', uri
      else
        system 'open', uri
      end
    end
    public_storage[:uris].clear
  end

  add_command /^uri-open\s+list\s*$/ do |m, t|
    puts public_storage[:uris]
  end

  add_command /^uri-open\s+clear\s*$/ do |m, t|
    public_storage[:uris].clear
    puts "clear uris"
  end
end
# ~/.termtter
# require 'plugin/uri-open'
#
# see also: http://ujihisa.nowa.jp/entry/c3dd00c4e0
#
# KNOWN BUG
# * In Debian, exit or C-c in the termtter kills your firefox.
