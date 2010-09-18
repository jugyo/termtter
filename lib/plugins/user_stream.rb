module Termtter::Client
  register_command(:"user_stream stop", :help => 'user_stream stop') do |arg|
    logger.info 'stopping user stream'
    if @user_stream_thread
      @user_stream_thread.exit
    end
    @user_stream_thread = nil
    plug "defaults/auto_reload"
  end

  handle_chunk = lambda { |chunk|
    data = Termtter::ActiveRubytter.new(JSON.parse(chunk)) rescue return
    Termtter::Client.logger.debug "user_stream: received #{JSON.parse(chunk).inspect}"
    begin
      if data[:event]
        if /list_/ =~ data[:event]
          typable_id = Termtter::Client.data_to_typable_id(data.target.id)
          print "\e[0G" + "\e[K" unless win?
          puts "[%s] %s %s %s to %s]" %
            [typable_id, data.source.screen_name, data.event, data.target.screen_name, data.target_object.uri]
          return
          Readline.refresh_line
        end
        if data[:target_object]
          # target_object is status
          source_user = data.source
          status = data.target_object
          typable_id = Termtter::Client.data_to_typable_id(status.id)
          print "\e[0G" + "\e[K" unless win?
          puts "[#{typable_id}] #{source_user.screen_name} #{data.event} #{status.user.screen_name}: #{status.text}"
          Readline.refresh_line
        else
          # target is user
          source_user = data.source
          target_user = data.target
          typable_id = Termtter::Client.data_to_typable_id(target_user.id)
          print "\e[0G" + "\e[K" unless win?
          puts "[#{typable_id}] #{source_user.screen_name} #{data.event} #{target_user.screen_name}"
          Readline.refresh_line
        end
      elsif data[:friends]
        print "\e[0G" + "\e[K" unless win?
        puts "You have #{data[:friends].length} friends."
        Readline.refresh_line
      elsif data[:delete]
        status = Termtter::API.twitter.safe.show(data.delete.status.id)
        print "\e[0G" + "\e[K" unless win?
        puts "#{status.user.screen_name} deleted: #{status.text}"
        Readline.refresh_line
      else
        print "\e[0G" + "\e[K" unless win?
        output([data], Termtter::Event.new(:update_friends_timeline, :type => :main))
        Termtter::API.twitter.store_status_cache(data)
        Readline.refresh_line
      end
    rescue Termtter::RubytterProxy::FrequentAccessError
      # ignore
    rescue Timeout::Error, StandardError => error
      new_error = error.class.new("#{error.message} (#{JSON.parse(chunk).inspect})")
      error.instance_variables.each{ |v|
        new_error.instance_variable_set(v, error.instance_variable_get(v))
      }
      handle_error new_error
    end
  }

  register_command(:"user_stream", :help => 'user_stream') do |arg|

    uri = URI.parse('http://betastream.twitter.com/2b/user.json')

    unless @user_stream_thread
      logger.info 'checking API status'
      1.times{ # to use break
        Termtter::HTTPpool.start(uri.host, uri.port){ |http|
          request = Net::HTTP::Get.new(uri.request_uri)
          request.oauth!(http, Termtter::API.twitter.consumer_token, Termtter::API.twitter.access_token)

          http.request(request){ |response|
            raise response.code.to_i unless response.code.to_i == 200
            break
          }
        }
      }
      logger.info 'API seems working'
    end

    execute('user_stream stop') if @user_stream_thread
    delete_task(:auto_reload)

    @user_stream_thread = Thread.new {
      loop do
        begin
          logger.info 'connecting to user stream'
          Termtter::HTTPpool.start(uri.host, uri.port){ |http|
            request = Net::HTTP::Get.new(uri.request_uri)
            request.oauth!(http, Termtter::API.twitter.consumer_token, Termtter::API.twitter.access_token)
            http.request(request){ |response|
              raise response.code.to_i unless response.code.to_i == 200
              raise 'Response is not chuncked' unless response.chunked?
              response.read_body{ |chunk|
                handle_chunk.call(chunk)
              }
            }
          }
        rescue Timeout::Error, StandardError => e
          handle_error e
          logger.info 'sleeping'
          sleep 10
        end
      end
    }
  end

  register_hook(
    :name => :user_stream_init,
    :author => '?', # FIXME
    :point => :initialize,
    :exec => lambda {
      execute('user_stream')
    })
end

# user_stream.rb
#
# to use,
#   > plug user_stream
#   > user_stream
#
# to stop,
#   > user_stream stop
#
# Specification
#   http://apiwiki.twitter.com/ChirpUserStreams
