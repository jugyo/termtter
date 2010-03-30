#-*- coding: utf-8 -*-
def say_cmd(s)
  return unless /darwin/i =~ RUBY_PLATFORM
  system 'say "'+s+'" >/dev/null 2> /dev/null'
end
Termtter::Client.register_command(
  :name => :nuance,
  :author => 'Sora Harakami',
  :help => ['nuance', 'how to say "termtter" in Japanese'],
  :exec => lambda do |arg|
    puts <<-EOM
== どのようにして'termtter'と発音するか ==
日本語発音されると「たーむったー」とします。
英語発音すると「たーむたー」とです。
    EOM
    if /darwin/i =~ RUBY_PLATFORM
      puts "こんなに発音されます。"
      say_cmd 'termtter'
      sleep 2
    end
    puts "補足情報:"
    puts <<-EOM
  [2010/3/28 6:54:22 PM] &ujihisa25: たーみったーとよんだひとは
  [2010/3/28 6:54:29 PM] &ujihisa25: あとで大変舐めに会うとか
    EOM
    Thread.new{say_cmd 'peropero'}
    puts "ぺろぺろ"
  end
)
