# -*- coding: utf-8 -*-

def plugin(name, init = {})
  warn "plugin method will be removed. Use Termtter::Client.plug instead."
  unless init.empty?
    init.each do |key, value|
      config.plugins.__refer__(name.to_sym).__assign__(key.to_sym, value)
    end
  end
  load "plugins/#{name}.rb"
rescue Exception => e
  Termtter::Client.handle_error(e)
end

def filter(name, init = {})
  warn "filter method will be removed. Use plugin instead."
  plugin(name, init)
end

