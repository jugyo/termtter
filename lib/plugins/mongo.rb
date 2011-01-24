require 'mongo'
config.plugins.mongo.set_default(:db_name, 'twitter')

module Termtter::Client
  db = Mongo::Connection.new.db(config.plugins.mongo.db_name)

  register_hook(
    :name => :user_stream_insert_mongo,
    :point => :user_stream_receive,
    :exec => lambda {|chunk|
      data = JSON.parse(chunk)

      coll_key = data['friends'] ? 'friends'
      : data['event'] ? 'event'
      : data['delete'] ? 'delete'
      : 'status'

      db.collection(coll_key).insert(data)
    })

end

# mongo.rb
