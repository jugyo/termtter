require 'pp'

module Termtter::Client
  register_command(
    :name => :"cache stats",
    :help => 'Show Memcached stats.',
    :exec_proc => lambda {|arg|
      puts memory_cache.stats.pretty_inspect
    })

  register_command(
    :name => :"cache flush",
    :help => 'Flush all caches.',
    :exec_proc => lambda {|arg|
      memory_cache.flush_all
      logger.info "cache flushed."
    })
end
