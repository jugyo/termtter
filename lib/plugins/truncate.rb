# -*- coding: utf-8 -*-

def multibyte_string(text)
  text.unpack('U*')
end

def truncate(text, length = 140, omission = "...")
  chars = multibyte_string(text)
  if chars.length > length
    _, text_base, urls =
      text.match(/\A(.*?)((?:\s+#{URI.regexp(%w(http https ftp))}\S*)*)\z/).to_a
    chars_base = multibyte_string(text_base)
    o = multibyte_string(omission + urls)
    if o.length >= length
      o = multibyte_string(omission)
      chars_base = chars
    end
    (chars_base[0...(length - o.length)] + o).pack('U*')
  else
    text
  end
end

Termtter::RubytterProxy.register_hook(
  :name => :truncate_status,
  :points => [:pre_update],
  :exec_proc => lambda do |*args|
    return unless args
    return args if args.length < 1
    status = args[0]
    return args if multibyte_string(status).length <= 140
    if Termtter::Client::confirm("Your status is longer than 140 characters. Is it OK to abbreviate it?", true)
      args[0] = truncate(status)
    else
      puts 'canceled.'
      raise Termtter::HookCanceled
    end
  end
)
