config.set_default(:logger, nil)
config.set_default(:update_interval, 120)
config.set_default(:prompt, '> ')
config.set_default(:devel, false)
config.set_default(:timeout, 5)
config.set_default(:retry, 1)
config.set_default(:splash, <<SPLASH)

   <cyan>&lt;(@)//_</cyan>  .  .      <on_green> Termtter <underline>#{Termtter::VERSION}</underline> </on_green>
      <cyan>\\\\</cyan>           <on_green> http://termtter.org/ </on_green>

SPLASH

config.system.set_default :cmd_mode, false
config.system.set_default :run_commands, []
config.system.set_default :load_plugins, []
config.system.set_default :disable_plugins, []
config.system.set_default :eval_scripts, []
