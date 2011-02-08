# -*- coding: utf-8 -*-

Termtter::Client::register_command(
  :name => :suspend,
  :help => ['suspend', 'suspends termtter'],
  :exec_proc => lambda {|arg| Process.kill :TSTP, $$ }
)

# see also: suspend command of bash, zsh, vim
