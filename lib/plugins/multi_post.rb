# -*- coding: utf-8 -*-

module Termtter::Client
  class << self
    def wassr_update(text)
      Net::HTTP.version_1_2
      req = Net::HTTP::Post.new("/statuses/update.json?")
      req.basic_auth config.plugins.wassr.username, config.plugins.wassr.password
      Net::HTTP.start('api.wassr.jp', 80) do |http|
        res = http.request(req, "status=#{URI.escape(text)}&source=Termtter")
      end
    end
  end
end

Termtter::Client.register_hook(
  :name => :multi_post,
  :points => [:modify_arg_for_update, :modify_arg_for_reply],
  :exec_proc => lambda {|cmd, arg|
    begin
      wassr_arg = arg.gsub(/\d{10,}/, '')
      Termtter::Client.wassr_update(wassr_arg.strip)
    rescue
      puts "RuntimeError: #{$!}"
    end

    return arg
  }
)

# multi_post.rb
# One post, multi update.
