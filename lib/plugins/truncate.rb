# -*- coding: utf-8 -*-

def truncate(text, length = 140, omission = "...")
  o = omission.unpack('U*')
  l = length - o.length
  chars = text.unpack 'U*'
  chars.length > length ? (chars[0...l] + o).pack('U*') : text
end

TRUNCATE_HOOK_COMMANDS = [:update, :reply]

Termtter::Client::register_hook(
  :name => :truncate_status,
  :points => TRUNCATE_HOOK_COMMANDS.map {|cmd|
    "modify_arg_for_#{cmd.to_s}".to_sym
  },
  :exec_proc => lambda do |cmd, arg|
    truncate(arg)
  end
)
