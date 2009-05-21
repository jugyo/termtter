# -*- coding: utf-8 -*-

## Need install "SayKana" & "MeCab (UTF-8)"
## SayKana
##   http://www.a-quest.com/aquestalk/saykana/
## MeCab
##   http://mecab.sourceforge.net/

require 'uri'

config.plugins.saykanji.set_default(:user_to_say, [])
config.plugins.saykanji.set_default(:keyword_to_say, [])
config.plugins.saykanji.set_default(:say_speed, 100)
config.plugins.saykanji.set_default(:kana_english_dict_path, "#{Termtter::CONF_DIR}/tmp/kana_english_dict.csv")

if config.plugins.saykanji.user_to_say.empty? &&
    config.plugins.saykanji.keyword_to_say.empty?
  config.plugins.saykanji.keyword_to_say = /./
end

def saykanji(text, say_speed)
  text_without_uri = text.gsub(URI.regexp(['http', 'https']), 'URI').
    gsub('～', '〜').gsub(/[－―]/, 'ー').gsub('&', 'アンド').
    delete("\n\`\'\"<>[]()|:;#")
  text_wakati = `echo #{text_without_uri}|mecab -O wakati`.split(' ')
  text_wakati.map!{ |i|
    if /[@a-zA-Z]/ =~ i && File.file?(config.plugins.saykanji.kana_english_dict_path)
      kana_english = `grep -i "\\"#{i}\\"" #{config.plugins.saykanji.kana_english_dict_path}`
      unless kana_english.empty?
        /^"(.+?)"/.match(kana_english).to_a[1]
      else
        i
      end
    elsif i == 'は'
      'ワ'
    elsif i == 'へ'
      'エ'
    else
      i
    end
  }
  text_to_say = `echo #{text_wakati.join}|mecab -O yomi`
  system "SayKana", "-s", "#{say_speed}", "#{text_to_say}"
end

def say(who, text)
  text_to_say = text.gsub(URI.regexp(['http', 'https']), 'U.R.I.')
  voices = %w(Alex Alex Bruce Fred Ralph Agnes Kathy Vicki)
  voice = voices[who.hash % voices.size]
  system 'say', '-v', voice, text_to_say
end

module Termtter::Client
  say_threads = []
  register_hook(:name => :saykanji,
                :point => :output,
                :exec_proc => lambda {|statuses, event|
                  return unless event == :update_friends_timeline
                  Thread.start do
                    say_threads.each { |t| t.join }
                    say_threads << Thread.start {
                      statuses.each do |s|
                        if /[ぁ-んァ-ヴ一-龠]/ =~ s.text
                          saykanji(s.text,
                                   config.plugins.saykanji.say_speed.to_i)
                        else
                          say(s.screen_name, s.text)
                        end
                      end
                    }
                  end
                }
                )

  register_hook(:name => :saykanji_filter,
                :point => :filter_for_saykanji,
                :exec => lambda { |statuses, event|
                  statuses.select do |s|
                    config.plugins.saykanji.user_to_say.include?(s.user.screen_name) ||
                    Regexp.union(*config.plugins.saykanji.keyword_to_say) =~ s.text
                  end
                }
                )
end
