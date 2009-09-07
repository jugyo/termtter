# -*- coding: utf-8 -*-

module Termtter::Client
  register_command(
    :name => :timer,
    :exec_proc => lambda{|arg|
      # argをparseする
      return unless arg =~ /^\d+$/
      after = arg.to_i
      Termtter::Client.add_task(:after => after) do
        text = "@#{config.user_name} 時間ですよ！！"
        Termtter::API.twitter.update text
        puts "=> " << text
      end
    },
    :help => ['timer SEC', 'post reminder after SEC.']
    )
end
