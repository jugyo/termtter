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

    CompletionProc = proc {|input|
      case input
      when /^l(ist)? +(.*)/
        username = $2
        if username.empty?
          Termtter::Client.public_storage[:users].to_a
        else
          Termtter::Client.public_storage[:users].to_a.
            grep(/^#{Regexp.quote username}/).map{|u| "list #{u}"}
        end
      when /^(update|u)\s+(.*)@([^\s]*)$/
        command, before, username = [$1, $2, $3]
        if username.empty?
          Termtter::Client.public_storage[:users].to_a
        else
          Termtter::Client.public_storage[:users].
            grep(/^#{Regexp.quote username}/i).map {|u| "#{command} #{before}@#{u}"}
        end
      when /^uri-open +(.*)/
        uri_open_com = $1
        if uri_open_com.empty?
          %w[clear list]
        else
          %w[clear list].
            grep(/^#{Regexp.quote uri_open_com}/).map{|c| "uri-open #{c}"}
        end
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
