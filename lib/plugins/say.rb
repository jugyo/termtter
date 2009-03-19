# -*- coding: utf-8 -*-

raise 'say.rb runs only in OSX Leopard' if /darwin9/ !~ RUBY_PLATFORM

# say :: String -> String -> IO ()
def say(who, what)
  voices = %w(Alex Alex Bruce Fred Ralph Agnes Kathy Vicki)
  voice = voices[who.hash % voices.size]
  system 'say', '-v', voice, what
end

module Termtter::Client
  register_hook(
    :name => :say,
    :points => [:post_filter],
    :exec_proc => lambda {|statuses, event|
      statuses.reverse.each do |s|
        text_without_uri = s[:post_text].gsub(%r|https?://[^\s]+|, 'U.R.I.')
        say s[:screen_name], text_without_uri
      end
    }
  )
end

# KNOWN BUG:
# * exit or <C-c> doen't work quickly.
