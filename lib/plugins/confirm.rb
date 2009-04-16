# -*- coding: utf-8 -*-

config.plugins.confirm.set_default(:commands, [:update, :reply, :direct])
config.plugins.confirm.set_default(
  :conditions,
  [
    lambda { |cmd_name, arg|
      if cmd_name == :direct && arg =~ /^(list|sent_list)$/
        false
      else
        true
      end
    }
  ]
)

Termtter::Client.register_hook(
  :name => :confirm,
  :points => [/^pre_exec_/],
  :exec_proc => lambda {|cmd, arg|
    if config.plugins.confirm.commands.include?(cmd.name) && 
        config.plugins.confirm.conditions.any? { |cond|  cond.call(cmd.name, arg) }

      prompt = "\"#{cmd.name} #{arg}".strip + "\" [Y/n] "

      if /^y?$/i !~ Readline.readline(prompt, false)
        puts 'canceled.'
        raise Termtter::CommandCanceled
      end

    end
  }
)
