require 'mongo'
config.plugins.mongo.set_default(:db_name, 'twitter')

module Termtter::Client
  class << self
    def mongo_db
      @mongo_db ||= Mongo::Connection.new.db(config.plugins.mongo.db_name)
    end
  end
end

module Termtter::Client
  register_hook(
    :name => :user_stream_insert_mongo,
    :point => :user_stream_receive,
    :exec => lambda {|chunk|
      data = JSON.parse(chunk)

      coll_key = data['friends'] ? 'friends'
      : data['event'] ? 'event'
      : data['delete'] ? 'delete'
      : 'status'

      mongo_db.collection(coll_key).insert(data)
    })

  register_command(
    :name => :mongo_favs,
    :alias => :mf,
    :exec_proc => lambda {|arg|
      table = {}
      mongo_db.collection('event').find({"event" => "favorite", "source.screen_name" => { "$ne" => config.user_name}}).sort(:$natural, -1).limit(50).to_a.reverse.each{|event|
        table[event['target_object']['id']] ||= {
          'status' => event['target_object'],
          'by' => []
        }
        table[event['target_object']['id']]['by'] << event['source']['screen_name']
      }
      table.to_a.sort_by{|pair| pair[0]}.each{|pair|
        status = pair[1]['status']
        by = pair[1]['by']
        puts "(#{by.length}) #{by.join(', ')}: #{status['text'].gsub(/\n/, ' ')}"
      }
    },
    :help => ["mongo_favs", "Print favorites from MongoDB"]
    )

  register_command(
    :name => :mongo_follows,
    :exec_proc => lambda {|arg|
      mongo_db.collection('event').find({event: "follow"}).sort(:$natural, -1).limit(50).to_a.reverse.each{|event|
        puts "#{event['source']['screen_name']} #{event['event']} #{event['target']['screen_name']}"
      }
    },
    :help => ["mongo_follows", "Print follows from MongoDB"]
    )
end

# mongo.rb

