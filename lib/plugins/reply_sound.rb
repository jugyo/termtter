#-*- coding: utf-8 -*-

# FIXME: This plugin is Mac only now.

if RUBY_PLATFORM =~ /darwin/i
config.plugins.reply_sound.set_default(:interval, 600)
config.plugins.reply_sound.set_default(:sound_file, '/System/Library/Sounds/Hero.aiff')

reply_sound_cache = nil

Termtter::Client.add_task(:name => :reply_sound,
                          :interval => config.plugins.reply_sound.interval) do
  replies = Termtter::API.twitter.replies
  if !reply_sound_cache.nil? && (replies - reply_sound_cache).size > 0
    system 'afplay "'+config.plugins.reply_sound.sound_file+'" 2>/dev/null &'
    Termtter::Client.output(replies - reply_sound_cache,:new_replies,:replies)
  end
  reply_sound_cache = replies
end



else
  puts TermColor.parse("<red>WARNING: reply_sound plugin is available on Mac OS X now.</red>")
end
