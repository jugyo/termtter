#-*- coding: utf-8 -*-

config.plugins.reply_sound.set_default(:interval, 600)

nul_port = /mswin/i =~ RUBY_PLATFORM ? "NUL" : "/dev/null"

reply_sound_cache = nil
reply_sound_cache_ids = []
not_supported = false
cmd_ok = false


Termtter::Client.register_hook(
  :name => :reply_sound_initialization,
  :point => :initialize,
  :exec => lambda do
    case RUBY_PLATFORM
    when /darwin/i
      config.plugins.reply_sound.set_default(
        :sound_file, '/System/Library/Sounds/Hero.aiff')
      config.plugins.reply_sound.set_default(
        :command, ['afplay', config.plugins.reply_sound.sound_file, {:out => nul_port, :err => nul_port}])
      cmd_ok = true
    when /linux/i
      case `uname -v`.chomp
      when /ubuntu/i
        config.plugins.reply_sound.set_default(
          :sound_file, '/usr/share/sounds/gnome/default/alerts/drip.ogg')
      else
        config.plugins.reply_sound.set_default(
          :sound_file, '')
      end
    else
      not_supported = true
      puts TermColor.parse(
        "<red>WARNING: Currently reply_sound plugin is not supported yet in your environment.</red>")
    end

    unless cmd_ok
      begin
        if /mplayer/i =~ `mplayer -v`.chomp
          config.plugins.reply_sound.set_default(
            :command, ['mplayer', config.plugins.reply_sound.sound_file, :out => nul_port, :err => nul_port])
          cmd_ok = true
          not_supported = false
        end
      rescue Errno::ENOENT
      end
    end

    unless not_supported
      d = false
      Termtter::Client.add_task(
        :name => :reply_sound_wait,
        :interval => 10) do
          break if d
          Termtter::Client.add_task(
            :name => :reply_sound,
            :interval => config.plugins.reply_sound.interval) do
              cmd = config.plugins.reply_sound.command.kind_of?(Array) ?
                config.plugins.reply_sound.command : [config.plugins.reply_sound.command]
              replies = Termtter::API.twitter.replies
              new_replies = replies.delete_if {|x| reply_sound_cache_ids.index(x[:id]) }
              if !reply_sound_cache.nil? && new_replies.size > 0
                if respond_to? :spawn, true
                  system *cmd
                else
                  spawn *cmd
                end
                print "\e[0G" + "\e[K" unless win?
                Termtter::Client.output(
                  new_replies, Termtter::Event.new(:new_replies,:type => :reply))
                Readline.refresh_line
              end
              reply_sound_cache = replies
              reply_sound_cache_ids += replies.map {|x| x[:id]}
            end
          d = true
        end
    end
  end)
