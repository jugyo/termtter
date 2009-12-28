# -*- coding: utf-8 -*-
config.set_default(:confirm, false)

def confirm(message)
  if config.confirm && !Termtter::Client.confirm(message)
    raise Termtter::CommandCanceled
  end
end

Termtter::RubytterProxy.register_hook(:confirm_update, :point => :pre_update) do |*args|
  confirm("update #{args.first}")
  args
end

Termtter::RubytterProxy.register_hook(:confirm_direct_message, :point => :pre_direct_message) do |*args|
  confirm("direct #{args[0]} #{args[1]}")
  args
end

Termtter::RubytterProxy.register_hook(:confirm_retweet, :point => :pre_retweet) do |*args|
  status = Termtter::API.twitter.show(args.first)
  confirm("retweet #{status.text}")
  args
end

Termtter::RubytterProxy.register_hook(:confirm_delete, :point => :pre_remove_status) do |*args|
  status = Termtter::API.twitter.show(args.first)
  confirm("delete #{status.text}")
  args
end
