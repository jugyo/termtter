module Termtter::Client

  register_command(:user_stream, :help => 'user_stream [stop]') do |arg|
    args = arg.split /[, ]/
    case args[0]
    when 'stop'
      puts 'stopping user stream'
      if @user_stream_thread
        @user_stream_thread.exit
      end
      @user_stream_thread = nil
    else
      execute('user_stream stop') if @user_stream_thread
      puts 'starting user stream'
      @user_stream_thread = Thread.new {
        loop do
          delete_task(:auto_reload)
          begin
            uri = URI.parse('http://chirpstream.twitter.com/2b/user.json')
            puts 'connecting to user stream'
            Net::HTTP.start(uri.host, uri.port) do |http|
              request = Net::HTTP::Get.new(uri.request_uri)
              request.basic_auth(config.user_name, config.password)
              http.request(request) do |response|
                raise 'Response is not chuncked' unless response.chunked?
                response.read_body do |chunk|
                  received = Termtter::ActiveRubytter.new(JSON.parse(chunk)) rescue next
                  begin
                    if received[:event]
                      if received[:target_object]
                        # target_object is status
                        source_user = Termtter::API.twitter.safe.user(received.source.id)
                        status = Termtter::API.twitter.safe.show(received.target_object.id)
                        typable_id = Termtter::Client.data_to_typable_id(status.id)
                        puts "[#{typable_id}] #{source_user.screen_name} #{received.event} #{status.user.screen_name}: #{status.text}"
                      else
                        # target is user
                        source_user = Termtter::API.twitter.safe.user(received.source.id)
                        target_user = Termtter::API.twitter.safe.user(received.target.id)
                        typable_id = Termtter::Client.data_to_typable_id(target_user.id)
                        puts "[#{typable_id}] #{source_user.screen_name} #{received.event} #{target_user.screen_name}"
                      end
                    elsif received[:friends]
                      puts "You have #{received[:friends].length} friends."
                    elsif received[:delete]
                      status = Termtter::API.twitter.safe.show(received.delete.status.id)
                      puts "#{status.user.screen_name} deleted: #{status.text}"
                    else
                      output([received], Termtter::Event.new(:update_friends_timeline))
                    end
                  rescue Timeout::Error, StandardError => error
                    new_error = error.class.new("#{error.message} (#{JSON.parse(chunk).inspect})")
                    error.instance_variables.each{ |v|
                      new_error.instance_variable_set(v, error.instance_variable_get(v))
                    }
                    handle_error new_error
                  end
                end
              end
            end
          rescue => e
            handle_error e
            sleep 1
          end
        end
      }
    end
  end

  register_hook(
    :name => :user_stream_init,
    :point => :initialize,
    :exec => lambda {
      execute('user_stream')
    })
end

# user_stream.rb

# to use,
#   > plug user_stream
#   > user_stream

# to stop,
#   > user_stream stop

# Spec
#   http://apiwiki.twitter.com/ChirpUserStreams
