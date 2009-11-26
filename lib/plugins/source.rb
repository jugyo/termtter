# -*- coding: utf-8 -*-
def __dir__
  File.dirname(File.expand_path(__FILE__))
end

def source(pluginname)
  a = Pathname(__dir__) + "#{pluginname}.rb"
  unless File.exist?(a)
    a = Pathname(__dir__) + "defaults/#{pluginname}.rb"
  end
  File.read(a)
end


module Termtter::Client
  register_command(:source, :help => ["source {plugin-name}", "shows the source code of the plugin"]) do |arg|
    puts source(arg)
  end

  register_command(:sourceyou, :help => ["sourceyou @username {plugin-name}", "gives the source code of the plugin"]) do |arg|
    /(\w+)\s(\w+)/ =~ arg
    text = "@#{normalize_as_user_name($1)} #{source($2)}".each_char.take(140).join
    Termtter::API.twitter.update(text)
  end
end
