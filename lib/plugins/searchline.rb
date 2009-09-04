# -*- coding: utf-8 -*-

config.plugins.searchline.set_default(:interval, 300)

module Termtter::Client
  class << self
    def delete_task(key)
      @task_manager.delete_task(key) # returns nil if task for key is not exist
    end
  end

  register_command(
    :name => :searchline,
    :exec => lambda {|arg|
      delete_task(:searchline)
      if arg == '-d'
        puts 'Stopped searchline.'
      else
        public_storage[:searchline_since_id] = 0
        add_task(:name => :searchline,
                 :interval => config.plugins.searchline.interval ) do
          begin
            statuses = Termtter::API.twitter.search(
              arg, 'since_id' => public_storage[:searchline_since_id] )
            unless statuses.empty?
              print "\e[0G" + "\e[K" unless win?
              public_storage[:searchline_since_id] = statuses[0].id
              output(statuses, SearchEvent.new(arg))
              Readline.refresh_line
            end
          rescue Exception => e
            handle_error(e)
          end
        end
      end
    },
    :help => ["searchline [TEXT|-d]", "Search for Twitter with auto reload"]
  )
end

# searchline.rb:
#   Search for Twitter with auto reload like friends_timeline.
# Caution:
#   Be aware of API limit.
