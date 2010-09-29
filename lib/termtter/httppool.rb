# -*- coding: utf-8 -*-
require 'net/http'
begin
  require 'net/https'
rescue LoadError; end

module Termtter
  module HTTPpool
    @@connections = {}
    @@http_class = nil

    def self.start(host, port = 80, ssl = false)
      count = config.retry || 3
      begin
        yield(connection(host, port, ssl))
      rescue EOFError
        finish(host, port)
        if count > 0
          count -= 1
          retry
        end
        raise
      end
    end

    def self.connection(host, port = 80, ssl = false)
      key = connection_key(host, port)
      http_io = http_class.new(host, port)
      http_io.use_ssl = ssl
      http_io.verify_mode = OpenSSL::SSL::VERIFY_NONE
      @@connections[key] ||= http_io.start
    end

    def self.finish(host, port = 80)
      key = connection_key(host, port)
      @@connections[key] && @@connections[key].do_finish rescue nil
      @@connections.delete(key)
    end

    def self.connection_key(host, port)
      port == 80 ? host : [host, port.to_s].join(':')
    end

    def self.http_class
      @@http_class ||=
        if config.proxy.host.nil? or config.proxy.host.empty?
          Net::HTTP
        else
          Net::HTTP::Proxy(
            config.proxy.host,
            config.proxy.port,
            config.proxy.user_name,
            config.proxy.password)
        end
    end

  end
end
