# -*- coding: utf-8 -*-
config.set_default(:confirm, false)
module Termtter
  RubytterProxy.register_hook(:confirm_update, :point => :pre_update) do |*args|
    if config.confirm && !Client.confirm("update #{args.first}")
      raise CommandCanceled
    end
    args
  end

  RubytterProxy.register_hook(:confirm_direct_message, :point => :pre_direct_message) do |*args|
    if config.confirm && !Client.confirm("direct #{args[0]} #{args[1]}")
      raise CommandCanceled
    end
    args
  end
end

