# -*- coding: utf-8 -*-

module Termtter::Client
  def self.delete_and_replace(recent, pattern_reg, replace, global)
    new_text =
      if global
        recent.text.gsub(pattern_reg, replace)
      else
        recent.text.sub(pattern_reg, replace)
      end

    param =
      if recent.in_reply_to_status_id
        {:in_reply_to_status_id => recent.in_reply_to_status_id}
      else
        {}
      end

    if new_text == recent.text
      puts "It was not replaced."
      raise Termtter::CommandCanceled
    end

    if /^y?$/i !~ Readline.readline("\"replace #{new_text}\" [Y/n] ", false)
      puts 'canceled.'
      raise Termtter::CommandCanceled
    else
      result = Termtter::API.twitter.remove_status(recent.id)
      puts "deleted => #{result.text}"
      result = Termtter::API.twitter.update(new_text, param)
      puts "updated => #{result.text}"
    end
  end

  register_command(:name => :replace,
                   :aliases => [:typo],
                   :help => ['replace,typo /PATTERN/REPLACE/',
                             'Delete and replace most recent tweet.'],
                   :exec_proc => lambda {|arg|
                     recent =
                     Termtter::API.twitter.user_timeline(:screen_name => config.user_name)[0]
                     pattern, replace, mode =
                     /^s?\/(.*?(?:(?!\\).))\/(.*)\/$/.match(arg).to_a.values_at(1, 2, 3)

                     if pattern == ""
                       puts "PATTERN is empty."
                       raise Termtter::CommandCanceled
                     end

                     delete_and_replace(recent, Regexp.new(pattern, /i/.match(mode)),
                                        replace, /g/ =~ mode)
                   }
                   )
end
