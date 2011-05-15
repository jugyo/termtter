module Termtter
  class UserStreamReceiver

    def run(&block)
      loop {
        begin
          self.process &block
        rescue => error
          Termtter::Client.handle_error error
          sleep 10
        end
      }
    end

    def self.repack_error(error, chunk)
      new_error = error.class.new("#{error.message} (#{JSON.parse(chunk).inspect})")
      error.instance_variables.each{ |v|
        new_error.instance_variable_set(v, error.instance_variable_get(v))
      }
      new_error
    rescue
      error
    end

    protected
    ENDPOINT = URI.parse('https://userstream.twitter.com/2/user.json')

    def process(&block)
      Termtter::Client.logger.info("connecting to UserStream")
      https = Net::HTTP.new(ENDPOINT.host, ENDPOINT.port)
      https.use_ssl = true
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE

      https.start{ |https|
        request = Net::HTTP::Get.new(ENDPOINT.request_uri)
        request.oauth!(https, Termtter::API.twitter.access_token.consumer, Termtter::API.twitter.access_token)
        https.request(request){ |response|
          raise StandardError, response.code.to_i unless response.code.to_i == 200
          raise StandardError, 'Response is not chuncked' unless response.chunked?
          Termtter::Client.logger.info("connected to UserStream")
          response.read_body{ |chunk|
            Termtter::Client.logger.debug("received: #{chunk}")
            yield chunk
          }
        }
      }
    end
  end
end

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
    Termtter::Client.clear_line
    begin
      if data[:event]
        if /list_/ =~ data[:event]
          typable_id = Termtter::Client.data_to_typable_id(data.target.id)
          puts "[%s] %s %s %s to %s]" %
            [typable_id, data.source.screen_name, data.event, data.target.screen_name, data.target_object.uri]
          return
        end
        if data[:target_object]
          # target_object is status
          source_user = data.source
          status = data.target_object
          typable_id = Termtter::Client.data_to_typable_id(status.id)
          puts "[#{typable_id}] #{source_user.screen_name} #{data.event} #{status.user.screen_name}: #{status.text}"
        else
          # target is user
          source_user = data.source
          target_user = data.target
          typable_id = Termtter::Client.data_to_typable_id(target_user.id)
          puts "[#{typable_id}] #{source_user.screen_name} #{data.event} #{target_user.screen_name}"
        end
      elsif data[:friends]
        puts "You have #{data[:friends].length} friends."
      elsif data[:delete]
        status = Termtter::API.twitter.cached_status(data.delete.status.id)
        puts "#{status.user.screen_name} deleted: #{status.text}"
      elsif data[:direct_message]
        dm = data[:direct_message]
        sender = dm.sender
        text = dm.text
        puts "[DM] #{sender.screen_name}: #{text}"
      else
        Termtter::API.twitter.store_status_cache(data)
        output([data], :update_friends_timeline)
      end
    rescue Timeout::Error, StandardError => error
      Termtter::Client.handle_error Termtter::UserStreamReceiver.repack_error(error, chunk)
    ensure
      Readline.refresh_line
    end
  }

  register_command(:"user_stream", :help => 'user_stream') do |arg|

    execute('user_stream stop') if @user_stream_thread
    delete_task(:auto_reload)

    @user_stream_thread = Thread.new {
      Termtter::UserStreamReceiver.new.run{|chunk|
        call_hooks(:user_stream_receive, chunk)
      }
    }
  end

  register_hook(
    :name => :user_stream_init,
    :point => :initialize,
    :exec => lambda {
      execute('user_stream')
    })

  register_hook(
    :name => :user_stream_print,
    :point => :user_stream_receive,
    :exec => lambda {|chunk|
      Thread.new {
        handle_chunk.call(chunk)
      }
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
