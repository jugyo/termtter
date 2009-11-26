# -*- coding: utf-8 -*-

def multibyte_string(text)
  text.unpack('U*')
end

def truncate(text, length = 140, omission = "...")
  o = multibyte_string(omission)
  l = length - o.length
  chars = multibyte_string(text)
  chars.length > length ? (chars[0...l] + o).pack('U*') : text
end

Termtter::RubytterProxy.register_hook(
  :name => :truncate_status,
  :points => [:pre_update],
  :exec_proc => lambda do |*args|
    return unless args
    return args if args.length < 1
    status = args[0]
    return args if multibyte_string(status).length <= 140
    if Termtter::Client::confirm("You are status contents more than 140 characters. do end endyou want abbreviation status?", true)
      args[0] = truncate(status)
    else
      puts 'canceled.'
      raise Termtter::HookCanceled
    end
  end
)
