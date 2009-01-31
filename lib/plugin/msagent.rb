# -*- coding: utf-8 -*-

raise 'msagent.rb runs only in windows' if RUBY_PLATFORM.downcase !~ /mswin(?!ce)|mingw|bccwin/

require 'win32ole'

require 'kconv'



agent = WIN32OLE.new('Agent.Control.2')

agent.connected = true

agent.characters.load("Merlin", ENV['WINDIR'] + "\\msagent\\chars\\Merlin.acs")

achar = agent.characters.character("Merlin")

achar.languageID = 0x411

achar.show



Termtter::Client.add_hook do |statuses, event, t|

  if event == :exit

    achar.hide   

    GC.start

  elsif !statuses.empty? && event == :update_friends_timeline

    statuses.reverse.each do |s|

      req = achar.speak("#{s.user_screen_name}: #{s.text}".tosjis)

      sleep 3

      WIN32OLE_EVENT.message_loop

      achar.stop(req)

    end

  end

end
