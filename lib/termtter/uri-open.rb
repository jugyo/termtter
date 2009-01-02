$uris = []
Termtter::Client.add_hook do |statuses, event|
  if !statuses.empty? && event == :update_friends_timeline
    statuses.each do |s|
      $uris += s.text.scan(%r|https?://[^\s]+|)
    end
  end
end
# ~/.termtter
# require 'termtter/uri-open'
#
# see also: http://ujihisa.nowa.jp/entry/c3dd00c4e0
