require 'uri'
require 'net/http'

module Termtter::Client
  # NOTE: overwrite original update command
  add_command /^(update|u)\s+(.*)/ do |m, t|
    text = ERB.new(m[2]).result(binding).gsub(/\n/, ' ')
    t.update_status(text)
    puts "=> #{text}"
    begin
      Net::HTTP.version_1_2
      req = Net::HTTP::Post.new("/statuses/update.json?")
      req.basic_auth configatron.plugins.wassr_post.username, configatron.plugins.wassr_post.password
      Net::HTTP.start('api.wassr.jp', 80) do |http|
        res = http.request(req, "status=#{URI.escape(text)}&via=Termtter")
      end
    rescue
      puts "RuntimeError: #{$!}"
    end
  end
end
