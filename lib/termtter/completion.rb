require 'set'

class Termtter::Client

  public_storage[:users] ||= Set.new

  add_hook do |statuses, event, t|
    if !statuses.empty?
      case event
      when :update_friends_timeline, :replies, :list_user_timeline
        statuses.each do |s|
          public_storage[:users].add(s.user_screen_name)
          s.text.scan(/@[a-zA-Z_0-9]*/).each do |u| # reply
            public_storage[:users].add(u.gsub("@","")) unless u == "@"
          end
        end
      end
    end
  end

end

module Termtter
  module InputCompletor

    Commands = %w[exit help list pause update resume replies search show uri-open]

    def self.find_candidates(a, b)
      if a.empty?
        Termtter::Client.public_storage[:users].to_a
      else
        Termtter::Client.public_storage[:users].
          grep(/^#{Regexp.quote a}/i).map {|u| b % u }
      end
    end

    CompletionProc = proc {|input|
      case input
      when /^l(ist)? +(.*)/
        find_candidates $2, "list %s"
      when /^(update|u)\s+(.*)@([^\s]*)$/
        find_candidates $3, "#{$1} #{$2}@%s"
      when /^uri-open +(.*)/
        find_candidates $1, "uri-open %s"
      else
        Commands.grep(/^#{Regexp.quote input}/)
      end
    }

  end
end

Readline.basic_word_break_characters= "\t\n\"\\'`><=;|&{("
Readline.completion_proc = Termtter::InputCompletor::CompletionProc

# author: bubbles
#
# see also: http://d.hatena.ne.jp/bubbles/20090105/1231145823
