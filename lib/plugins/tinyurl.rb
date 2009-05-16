# -*- coding: utf-8 -*-

TINYURL_HOOK_COMMANDS = [:update, :reply]
URI_REGEXP = URI.regexp(%w(http https ftp))

Termtter::Client.register_hook(
  :name => :tinyurl,
  :points => TINYURL_HOOK_COMMANDS.map {|cmd|
    "modify_arg_for_#{cmd.to_s}".to_sym
  },
  :exec_proc => lambda {|cmd, arg|
    arg = arg.gsub(URI_REGEXP) do |url|
      Termtter::API.connection.start('tinyurl.com', 80) do |http|
        http.get('/api-create.php?url=' + URI.escape(url)).body
      end
    end
  }
)

# tinyuri.rb
# make URLs in your update to convert tinyurl.com/XXXXXXX.
