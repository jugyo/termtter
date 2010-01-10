config.set_default(:logger, nil)
config.set_default(:update_interval, 120)
config.set_default(:prompt, '> ')
config.set_default(:devel, false)
config.set_default(:timeout, 5)
config.set_default(:retry, 1)
config.set_default(:splash, <<SPLASH)
<cyan>
   &lt;(@)//_ . . <underline>Termtter</underline> <red>#{Termtter::VERSION}</red> . . . .
      \\\\
</cyan>
SPLASH

config.system.set_default :conf_dir, File.expand_path('~/.termtter')
config.system.set_default :conf_file, config.system.conf_dir + '/config'
config.system.set_default :cmd_mode, false
config.system.set_default :run_commands, []
config.system.set_default :load_plugins, []
config.system.set_default :disable_plugins, []
config.system.set_default :eval_scripts, []
