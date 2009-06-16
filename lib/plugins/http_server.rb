# http_server
#
# = REQUIREMENTS
# * mime-types
#

require 'mime/types'
require 'pathname'
require 'webrick'
require 'logger'

config.plugins.http_server.set_default(:port, 5678)

module Termtter::Client
  if @http_server
    @http_server.shutdown # for reload
  end

  register_hook(:http_server_output, :point => :output) do |statuses, event|
    @http_server_output = statuses.to_json
  end

  register_hook(:http_server_shutdown, :point => :exit) do
    @http_server.shutdown
  end

  @http_server_logger = Logger.new(STDOUT)
  @http_server_logger.level = Logger::WARN
  @http_server = WEBrick::HTTPServer.new(
    :BindAddress => '127.0.0.1',
    :Port => config.plugins.http_server.port,
    :Logger => @http_server_logger,
    :AccessLog => []
  )

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
