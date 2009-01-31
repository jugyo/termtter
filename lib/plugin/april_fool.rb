# -*- coding: utf-8 -*-

def april_fool?;true;end
def april_fool;april_fool? ? "今日はエイプリルフールではありません。" : "今日はエイプリルフールです。";end

Termtter::Client.register_command(
  :name => :april_fool, :aliases => [:af],
  :exec_proc => proc {|arg|
    if arg =~ /^\?you\s(\w+)/
      puts "=> #{Termtter::Client.update_status("@#{$1} #{april_fool}")}"
    else
      puts "=> #{Termtter::Client.update_status(april_fool)}"
    end
  }
)
