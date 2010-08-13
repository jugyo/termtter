# -*- coding: utf-8 -*-
begin
  require 'appscript'
rescue LoadError
  raise "itunes plug: can't load appscript gem. please run 'gem install rb-appscript'"
end

config.plugins.itunes.set_default(:prefix, 'Listening now:')
config.plugins.itunes.set_default(:suffix, '#iTunes #listening')
config.plugins.itunes.set_default(:format,
  '<%=prefix%> <%=track_name%> (<%=time%>) <%=artist%> <%=album%> <%=suffix%>')

Termtter::Client.register_command(
  :name => :listening_now, :aliases => [:ln, :itunes, :music, :m],
  :help => ['listening_now,ln,itunes,music', "Post the information of listening now."],
  :exec => lambda {|args|
    begin
      prefix     = config.plugins.itunes.prefix
      track_name = Appscript.app('iTunes').current_track.name.get
      artist     = Appscript.app('iTunes').current_track.artist.get
      genre      = Appscript.app('iTunes').current_track.genre.get
      time       = Appscript.app('iTunes').current_track.time.get
      album      = Appscript.app('iTunes').current_track.album.get
      suffix     = config.plugins.itunes.suffix
      erbed_text = ERB.new(config.plugins.itunes.format).result(binding)
      erbed_text.gsub!(/\s{2,}/, ' ')
      if args.length > 0
        erbed_text = args + ' ' + erbed_text
      end
      Termtter::API.twitter.update(erbed_text)
      puts "=> " << erbed_text
    rescue => e
      p e
    end
  }
)
