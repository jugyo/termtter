module Termtter::Client
  public_storage[:uris] = []

  add_hook do |statuses, event, t|
    if !statuses.empty? && event == :update_friends_timeline
      statuses.each do |s|
        public_storage[:uris] += s.text.scan(%r|https?://[^\s]+|)
      end
    end
  end

  def self.open_uri(uri)
    case RUBY_PLATFORM
    when /linux/
      system 'firefox', uri
    when /mswin(?!ce)|mingw|bccwin/
      system 'explorer', uri
    else
      system 'open', uri
    end
  end

  add_command /^uri-open\s*$/ do |m, t|
    public_storage[:uris].each do |uri|
      open_uri(uri)
    end
    public_storage[:uris].clear
  end

  add_command /^uri-open\s+(\d+)$/ do |m, t|
    if m[1]
      index = m[1].to_i
      open_uri(public_storage[:uris][index])
      public_storage[:uris].delete_at(index)
    end
  end

  add_command /^uri-open\s+list\s*$/ do |m, t|
    public_storage[:uris].each_with_index do |uri, index|
      puts "#{index}: #{uri}"
    end
  end

  add_command /^uri-open\s+delete\s+(\d+)$/ do |m, t|
    public_storage[:uris].delete_at(m[1].to_i) if m[1]
  end

  add_command /^uri-open\s+clear\s*$/ do |m, t|
    public_storage[:uris].clear
    puts "clear uris"
  end

  add_completion do |input|
    ['uri-open ', 'uri-open list', 'uri-open delete', 'uri-open clear'].grep(/^#{Regexp.quote input}/)
  end
end
# ~/.termtter
# plugin 'uri-open'
#
# see also: http://ujihisa.nowa.jp/entry/c3dd00c4e0
#
# KNOWN BUG
# * In Debian, exit or C-c in the termtter kills your firefox.
