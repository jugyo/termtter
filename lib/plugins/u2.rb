# -*- coding: utf-8 -*-

module Termtter::Client
  register_command(
    :name => :reply,
    :exec_proc => lambda {|arg|
      case arg
      when /^\s*(?:list)?\s*$/
        public_storage[:log].each_with_index do |s, i|
          puts "#{i}: #{s.user.screen_name}: #{s.text}"
        end
      when /^\s*u(?:pdate)?\s+(\d+)\s+(.+)$/
        id   = public_storage[:log][$1.to_i].id
        user = public_storage[:log][$1.to_i].user.screen_name
        text = ERB.new("@#{user} #{$2}").result(binding).gsub(/\n/, ' ')
        result = Termtter::API.twitter.update(text, {'in_reply_to_status_id' => id})
        puts "=> #{text}"
        result
      when /^\s*(\d+)\s+(.+)$/
        id   = $1
        text = ERB.new($2).result(binding).gsub(/\n/, ' ')
        result = Termtter::API.twitter.update(text, {'in_reply_to_status_id' => id})
        puts "=> #{text}"
        result
      end
    },
    :completion_proc => lambda {|cmd, args|
      #todo
    },
  )
end

=begin
= Termtter reply command
== Usage
=== list
* ステータスのリストを連番と一緒に出す。
 command: reply [list]
 > reply
 0: foo: foo's message
 1: bar: bar's message
 ..

=== reply
* 上記listコマンドで出したステータスNOに対してメッセージを送る。
* メッセージ送信の際、@usernameが自動的に付与される。
 command: reply [u|update] status_no message
 > reply u 0 message4foo

=== reply
* 対象のstatus_idを自分で入力してメッセージを送信する。
 command: reply status_id message

== Todo
* 英語で説明
* リファクタ
* 補完
* できたらファイル名をreply.rbにする。
=end
