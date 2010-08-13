config.plugins.short_logger.set_default(:length, 30)

Termtter::Client.register_hook(
  :name => :setup_short_logger,
  :point => :post_setup_logger,
  :exec => lambda {
    logger = Termtter::Client.logger
    original = logger.formatter
    length = config.plugins.short_logger.length
    logger.formatter = lambda {|severity, time, progname, message|
      message = message[0...length] + " ..." if message.size >= length unless config.devel
      original.call(severity, time, progname, message)
    }
  }
)
