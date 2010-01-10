#-*- coding: utf-8 -*-

config.set_default('footer',nil)

Termtter::Client.register_hook(
  :name => :add_footer,
  :points => [:modify_arg_for_update, :modify_arg_for_reply],
  :exec => lambda {|cmd, arg| 
                    (config.footer.nil? || config.footer.empty?) ? arg : arg + " #{config.footer}"
                  }
)

Termtter::Client.register_command(
  :name => :footer,
  :aliases => [:ft],
  :exec => lambda {|arg|
                    arg.empty? ? config.footer = nil : config.footer = arg
                    puts config.footer.nil? ? "footer is turned off" : "new footer=> #{config.footer}"
                  } 
)


