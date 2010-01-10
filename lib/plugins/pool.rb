# -*- coding: utf-8 -*-

require 'drb/drb'
require 'rinda/tuplespace'

config.plugins.pool.set_default(:port, '12354')

pool = Rinda::TupleSpace.new
DRb.start_service("druby://:#{config.plugins.pool.port}", pool)

Thread.new do
  loop do
    statement = pool.take([:statement, nil])
    print 'pool: '
    Termtter::Client.execute("update #{statement[1]}")
    STDOUT.flush
  end
end

# pool plugin allow remote update
# e.g)
#
# require 'drb/drb'
#
# DRb.start_service
# pool = DRbObject.new_with_uri('http://localhost:12354')
# pool.write(['statement', 'hey!'])
#
# run above code and you show 'pool: updated => hey
#
