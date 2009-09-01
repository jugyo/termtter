# -*- coding: utf-8 -*-

config.plugins.mark.set_default(
  :text, '<on_green>' + (' ' * 30) + '#mark' + (' ' * 30) + '</on_green>')

Termtter::Client.register_command(
  :name => :mark, :alias => :m, 
  :exec => lambda {|arg|
    puts TermColor.parse(config.plugins.mark.text)
  }
)
