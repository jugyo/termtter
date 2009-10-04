# -*- coding: utf-8 -*-

Termtter::Client.register_hook(:modify_arg_hook_sample, :point => :modify_arg_for_update) do |cmd, arg|
  arg + ' ＼(＾o＾)／'
end
