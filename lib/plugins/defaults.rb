# -*- coding: utf-8 -*-

module Termtter::Client
  # TODO: the below could be unnecessary
  config.set_default(:stdout, true)
  config.set_default(:standard_commands, true)
  config.set_default(:standard_completion, true)
  config.set_default(:auto_reload, true)

  defaults = Dir[File.dirname(__FILE__) + '/defaults/*.rb'].map { |f|
    f.match(%r|defaults/(.*?).rb$|)[1]
  }.each { |plugin|
    plug "defaults/#{plugin}" if config.__refer__(plugin.to_sym)
  }
end
