config.plugins.copy.set_default(:style, "@<%= t.user.screen_name %>: <%= t.text %> [ <%= url %> ]")

def copy_to_clipboard(str)
  if /darwin/i =~ RUBY_PLATFORM
    IO.popen("pbcopy", "w") do |io|
      io.print str
    end
  else
    puts "Sorry, this plugin is only in Mac OS X."
  end
  str
end

Termtter::Client.plug 'url'

Termtter::Client.register_command(:name => :copy,
                                  :exec => lambda do |arg|
  t = Termtter::API.twitter.show(arg)
  url = url_by_tweet(t)
  erbed_text = ERB.new(config.plugins.copy.style).result(binding)

  puts "Copied=> #{copy_to_clipboard(erbed_text)}"
end)

Termtter::Client.register_command(:name => :copy_url,
                                  :exec => lambda do |arg|
  t = Termtter::API.twitter.show(arg)
  url = url_by_tweet(t)

  puts "Copied=> #{copy_to_clipboard(url)}"
  
end)
