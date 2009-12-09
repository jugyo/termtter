# -*- coding: utf-8 -*-
config.set_default(:confirm, false)
module Termtter
  RubytterProxy.register_hook(:confirm, :point => :pre_update) do |*args|
    if config.confirm && !Client.confirm("update #{args.first}")
      raise CommandCanceled
    end
    args
  end
end

