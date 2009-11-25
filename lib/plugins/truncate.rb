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

unless Object.const_defined?(:TRUNCATE_HOOK_COMMANDS)
  TRUNCATE_HOOK_COMMANDS = [:update, :reply, :retweet]
end

Termtter::Client::register_hook(
  :name => :truncate_status,
  :points => TRUNCATE_HOOK_COMMANDS.map {|cmd|
    "modify_arg_for_#{cmd.to_s}".to_sym
  },
  :exec_proc => lambda do |cmd, arg|
    return arg if multibyte_string(arg).length <= 140
    if Termtter::Client::confirm("You are status contents more than 140 characters. Do you want abbreviation status?", true)
      truncate(arg)
    else
      puts 'canceled.'
      raise Termtter::CommandCanceled
    end
  end
)
