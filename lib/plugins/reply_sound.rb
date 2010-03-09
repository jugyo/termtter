#-*- coding: utf-8 -*-

# FIXME: Currently this plugin is available only on Mac OS X.

if RUBY_PLATFORM =~ /darwin/i
  config.plugins.reply_sound.set_default(:interval, 600)
  config.plugins.reply_sound.set_default(:sound_file, '/System/Library/Sounds/Hero.aiff')

  reply_sound_cache = nil
  reply_sound_cache_ids = []

  Termtter::Client.add_task(:name => :reply_sound,
                            :interval => config.plugins.reply_sound.interval) do
    replies = Termtter::API.twitter.replies
    new_replies = replies.delete_if{|x| reply_sound_cache_ids.index(x[:id]) }
    if !reply_sound_cache.nil? && new_replies.size > 0
      system 'afplay "'+config.plugins.reply_sound.sound_file+'" 2>/dev/null &'
      Termtter::Client.output(new_replies,Termtter::Event.new(:new_replies,:type => :reply))
    end
    reply_sound_cache = replies
    reply_sound_cache_ids += replies.map{|x| x[:id]}
  end
else
  puts TermColor.parse("<red>WARNING: Currently reply_sound plugin is available only on Mac OS X.</red>")
end
