# http_server
#
# = REQUIREMENTS
# * mime-types
# * rubytter >= 0.8.0 (for web client)
#

require 'mime/types'
require 'pathname'
require 'webrick'
require 'logger'

config.plugins.http_server.set_default(:port, 5678)
config.plugins.http_server.set_default(:reload_max_count, 100)

module Termtter::Client
  if @http_server
    @http_server.shutdown # for reload
  end

  @http_server_statuses_store = []

  register_hook(:http_server_output, :point => :output) do |statuses, event|
    @http_server_output = statuses.to_json
    if event == :update_friends_timeline
      @http_server_statuses_store += statuses
      max = config.plugins.http_server.reload_max_count
      if @http_server_statuses_store.size > max
        from = @http_server_statuses_store.size - max
        @http_server_statuses_store = @http_server_statuses_store[from..-1]
      end
    end
  end

  register_hook(:http_server_shutdown, :point => :exit) do
    @http_server.shutdown
  end

  @http_server_logger = Logger.new(nil)
  @http_server_logger.level = Logger::WARN
  @http_server = WEBrick::HTTPServer.new(
    :BindAddress => '127.0.0.1',
    :Port => config.plugins.http_server.port,
    :Logger => @http_server_logger,
    :AccessLog => []
  )

  @http_server.mount_proc('/reload.html') do |req, res|
    # MEMO: ブラウザで画面を二つ開いてるとデータの取り合いになっておかしな感じになる。。。
    res['Content-Type'] = 'text/javascript; charset=utf-8';
    res.body = @http_server_statuses_store.to_json
    @http_server_statuses_store.clear
  end

  @http_server.mount_proc('/') do |req, res|
    request_path = req.path == '/' ? 'index.html' : req.path
    base_name = Pathname.new(request_path).basename.to_s
    file_path = File.dirname(__FILE__) + '/http_server/' + base_name

    if File.file?(file_path)
      # send a file
      res.header["Content-Type"] = MIME::Types.type_for(file_path).first.content_type
      res.body = File.open(file_path, 'rb').read
    else
      # execute a command
      @http_server_output = ''
      begin
        command = req.path.sub(/^\//, '')
        call_commands(command)
        res['Content-Type'] = 'text/javascript; charset=utf-8';
        res.body = @http_server_output
      rescue Termtter::CommandNotFound => e
        res.status = 404
        res.body = "Command Not Found!!"
      end
    end
  end

  Thread.start do
    @http_server.start
  end
end
