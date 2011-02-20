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
      mongo_db.collection('event').find({"event" => "favorite", "source.screen_name" => { "$ne" => config.user_name}}).sort(:_id, -1).limit(100).to_a.reverse.each{|event|
        table[event['target_object']['id']] ||= {
          'status' => event['target_object'],
          'fav_by' => [],
          'rt_by' => [],
        }
        table[event['target_object']['id']]['fav_by'] << event['source']['screen_name']
      }
      mongo_db.collection('status').find({"retweeted_status.user.screen_name" => config.user_name}).sort(:_id, -1).limit(100).to_a.reverse.each{|status|
        table[status['retweeted_status']['id']] ||= {
          'status' => status['retweeted_status'],
          'fav_by' => [],
          'rt_by' => [],
        }
        table[status['retweeted_status']['id']]['rt_by'] << status['user']['screen_name']
      }

      table.to_a.sort_by{|pair| pair[0]}[-40..-1].each{|pair|
        status = pair[1]['status']
        fav_by = pair[1]['fav_by']
        rt_by = pair[1]['rt_by']
        puts [
          fav_by.empty? ? nil : "fav(#{fav_by.length}) #{fav_by.join(', ')}",
          rt_by.empty? ? nil : "RT(#{rt_by.length}) #{rt_by.join(', ')}",
          status['text'].gsub(/\n/, ' ')
        ].compact.join(' ')
      }
    },
    :help => ["mongo_favs", "Print favorites from MongoDB"]
    )

  register_command(
    :name => :mongo_search,
    :alias => :ms,
    :exec_proc => lambda {|arg|
      limit = 20
      arg.gsub!(/-(\d+) /){|n| limit = $1.to_i; ''}
      arg.strip!

      statuses = mongo_db.collection('status').find({
          'text' => Regexp.new(Regexp.quote(arg))
        }).sort(:$natural, -1).limit(limit).to_a.reverse.map{|s|
        Termtter::ActiveRubytter.new(s)
      }
      output(statuses, Termtter::Client::SearchEvent.new(arg))
    },
      :help => ["mongo_search", "Search from MongoDB"]
    )

  register_command(
    :name => :mongo_list,
    :alias => :ml,
    :exec_proc => lambda {|arg|
      limit = 20
      arg.gsub!(/-(\d+) /){|n| limit = $1.to_i; ''}

      users = arg.strip.split(/\s+/).map{|name| Termtter::Client.normalize_as_user_name(name) }

      query = users.empty? ? {} : {'user.screen_name' => {'$in' => users}}

      statuses = mongo_db.collection('status').find(query).sort(:$natural, -1).limit(limit).to_a.reverse.map{|s|
        Termtter::ActiveRubytter.new(s)
      }
      output(statuses)
    },
      :help => ["mongo_list", "List the posts from MongoDB"]
    )

end

class Termtter::RubytterProxy
  def cached_status(status_id)
    status = Termtter::Client.memory_cache.get(['status', status_id].join('-'))
    status ||= Termtter::Client.mongo_db.collection('status').find_one({'id' => status_id.to_i})
    Termtter::ActiveRubytter.new(status) if status
  end
end


# mongo.rb

