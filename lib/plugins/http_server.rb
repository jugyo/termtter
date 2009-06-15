require 'webrick'
require 'logger'

module Termtter::Client
  register_hook(:http_server_output, :point => :output) do |statuses, event|
    @http_server_output = statuses.to_json
  end

  register_hook(:http_server_shutdown, :point => :exit) do
    @http_server.shutdown
  end

  @http_server_logger = Logger.new(STDOUT)
  @http_server_logger.level = Logger::WARN
  @http_server = WEBrick::HTTPServer.new(
    :BindAddress => '127.0.0.1', :Port => 3000, :Logger => @http_server_logger, :AccessLog => [])

  @http_server.mount_proc('/') do |req, res|
    @http_server_output = ''
    begin
      command = req.path.sub(/^\/+/, '')
      call_commands(command)
      res['Content-Type'] = 'text/javascript; charset=utf-8';
      res.body = @http_server_output
    rescue Termtter::CommandNotFound => e
      res.status = 404
      res.body = "Command Not Found!!"
    end
  end

  Thread.start do
    @http_server.start
  end
end
