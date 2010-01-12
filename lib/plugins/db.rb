# -*- coding: utf-8 -*-

config.plugins.db.set_default(:path, Termtter::CONF_DIR + '/termtter.db')
config.plugins.db.set_default(:engine, 'sequel_db')

Termtter::Client.plug 'db/' + config.plugins.db.engine
