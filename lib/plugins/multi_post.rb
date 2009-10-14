# -*- coding: utf-8 -*-

module Termtter::Client
  class << self
    def wassr_update(text)
      if text.match(/^(\d+)\s+(.+)$/) and
          (s = Termtter::API.twitter.show($1) rescue nil)
        tmp_text = "@#{s.user.screen_name} #{$2}"
      else
        tmp_text = text
      end

      Net::HTTP.version_1_2
      req = Net::HTTP::Post.new("/statuses/update.json?")
      req.basic_auth config.plugins.wassr.username, config.plugins.wassr.password
      Net::HTTP.start('api.wassr.jp', 80) do |http|
        res = http.request(req, "status=#{URI.escape(tmp_text)}&source=Termtter")
      end
    end
  end

  register_hook(
    :name => :multi_post,
    :points => [:post_exec_update, :post_exec_reply, :post_exec_retweet],
    :exec_proc => lambda {|cmd, arg, result|
      prefix = config.plugins.stdout.typable_id_prefix
      if result
        wassr_arg = result
      elsif arg.match(/(\$([a-z]{2}))/) and
          s = Termtter::API.twitter.show(typable_id_to_data($2))
        wassr_arg = arg.sub($1, "@" + s.user.screen_name)
      else
        wassr_arg = arg
      end

      begin
        Termtter::Client.wassr_update(wassr_arg.strip)
      rescue
        puts "RuntimeError: #{$!}"
      end
    }
  )
end


# multi_post.rb
# One post, multi update.
