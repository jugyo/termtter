# -*- coding: utf-8 -*-

SHORTURL_MAKERS = [
  { :host => "api.bit.ly",
    :format => '/shorten?version=2.0.1&longUrl=%s&login=termtter&apiKey=R_e7f22d523a803dbff7f67de18c109856' },
  { :host => "is.gd", :format => '/api.php?longurl=%s' },
  { :host => "tinyurl.com", :format => '/api-create.php?url=%s' },
]
TINYURL_HOOK_COMMANDS = [:update, :reply]
URI_REGEXP = URI.regexp(%w(http https ftp))

Termtter::Client.register_hook(
  :name => :tinyurl,
  :points => TINYURL_HOOK_COMMANDS.map {|cmd|
    "modify_arg_for_#{cmd.to_s}".to_sym
  },
  :exec_proc => lambda {|cmd, arg|
    arg.split(' ').map {|component|
      result = component
      if component =~ URI_REGEXP
        url_enc = URI.escape(component, /[^a-zA-Z0-9.:]/)
        SHORTURL_MAKERS.each do |site|
          res = Termtter::HTTPpool.start(site[:host]) do |h|
            h.get(site[:format] % url_enc)
          end
          if res.code == '200'
            result = res.body
            if result =~ /"shortUrl": "(http.*)"/
              result = $1
            end
            break
          end
        end
      end
      result
    }.join(' ')
  }
)

# tinyuri.rb
# make URLs in your update to convert tinyurl.com/XXXXXXX.
