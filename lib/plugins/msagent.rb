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

Termtter::Client.register_hook(
  :name => :msagent,
  :points => [:post_filter],
  :exec_proc => lambda {|statuses, event|
    if !statuses.empty? && event == :update_friends_timeline
      Thread.start do
        statuses.reverse.each do |s|
          req = achar.speak("#{s[:screen_name]}: #{s[:text]}".tosjis)
          sleep 1
          WIN32OLE_EVENT.message_loop
          achar.stop(req)
        end
      end
    end
  }
)

Termtter::Client.register_hook(
  :name => :msagent_exit,
  :points => [:exit],
  :exec_proc => lambda {
    achar.hide   
    GC.start
  }
)
