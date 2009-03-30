# -*- coding: utf-8 -*-

module Termtter::Client
  register_command(
    :name => :reply,
    :aliases => [:re],
    :exec_proc => lambda {|arg|
      case arg
      when /^\s*(?:list)?\s*$/
        public_storage[:log4re] = public_storage[:log].sort {|a,b| a.id <=> b.id}
        public_storage[:log4re].each_with_index do |s, i|
          puts "#{i}: #{s.user.screen_name}: #{s.text}"
        end
      when /^\s*(\d+)\s+(.+)$/
        id   = public_storage[:log4re][$1.to_i].id
        user = public_storage[:log4re][$1.to_i].user.screen_name
        text = ERB.new("@#{user} #{$2}").result(binding).gsub(/\n/, ' ')
        result = Termtter::API.twitter.update(text, {'in_reply_to_status_id' => id})
        puts "=> #{text}"
        public_storage.delete :log4re
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

== Todo
* 英語で説明
* リファクタ
* 補完
* できたらファイル名をreply.rbにする。
=end
