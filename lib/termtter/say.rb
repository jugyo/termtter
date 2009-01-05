raise 'say.rb runs only in OSX Leopard' if /darwin9/ !~ RUBY_PLATFORM

# say :: String -> String -> IO ()
def say(who, what)
  voices = %w(Alex Bruce Fred Junior Ralph Agnes Kathy Princess Vicki Victoria Albert Bad\ News Bahh Bells Boing Bubbles Cellos Deranged Good\ News Hysterical Pipe\ Organ Trinoids Whisper Zarvox)
  voice = voices[who.hash % voices.size]
  system 'say', '-v', voice, what
end

module Termtter::Client
  add_hook do |statuses, event, t|
    if !statuses.empty? && event == :update_friends_timeline
      statuses.reverse.each do |s|
        text_without_uri = s.text.gsub(%r|https?://[^\s]+|, 'U.R.I.')
        say s.user_screen_name, text_without_uri
      end
    end
  end
end

# KNOWN BUG:
# * exit or <C-c> doen't work quickly.
